import AVFoundation
import Darwin
import Foundation
import os

/// Sample-accurate JJY audio signal transmitter using AVAudioEngine + AVAudioSourceNode.
///
/// Generates a continuous phase-coherent 13.333 kHz (for 40 kHz JJY) or 20 kHz (for 60 kHz JJY)
/// sine wave gated on and off by the NICT JJY pulse durations (0.8 s / 0.5 s / 0.2 s),
/// aligned to system wall-clock UTC seconds with hardware output latency compensation.
final class JJYTransmitter {
    private struct RenderState: Sendable {
        var isActive: Bool = false
        var phaseIncrement: Double = 0
        var invSampleRate: Double = 0
        var hostTicksToSeconds: Double = 0
        var hostToWallOffset: Double = 0
        var outputLatency: Double = 0
        var startUnixSecond: Double = 0
        var m0: PackedJJYMinute = .empty
        var m1: PackedJJYMinute = .empty
        var m2: PackedJJYMinute = .empty
        var m3: PackedJJYMinute = .empty

        @inline(__always)
        func highDuration(minuteIndex: Int64, second: Int) -> Double {
            if m0.unixMinute == minuteIndex { return m0.highDuration(atSecond: second) }
            if m1.unixMinute == minuteIndex { return m1.highDuration(atSecond: second) }
            if m2.unixMinute == minuteIndex { return m2.highDuration(atSecond: second) }
            if m3.unixMinute == minuteIndex { return m3.highDuration(atSecond: second) }
            return 0.0
        }
    }

    /// Callback invoked on the main queue if audio stops due to an OS interruption or headphone unplug.
    var onUnexpectedStop: (() -> Void)?

    private let stateLock = OSAllocatedUnfairLock(initialState: RenderState())
    private let hostTicksToSeconds: Double

    private var engine: AVAudioEngine?
    private var sourceNode: AVAudioSourceNode?
    private var scheduleTimer: Timer?
    private var observers: [NSObjectProtocol] = []

    private var activeFrequency: JJYFrequency = .khz40
    private var activeTimeZone: TimeZone = .current
    private var isRunning: Bool = false

    init() {
        var info = mach_timebase_info_data_t()
        mach_timebase_info(&info)
        if info.denom != 0 {
            self.hostTicksToSeconds = (Double(info.numer) / Double(info.denom)) * 1e-9
        } else {
            self.hostTicksToSeconds = 1e-9
        }
    }

    deinit {
        stop()
    }

    /// Starts transmitting the JJY signal for `timeZone` at `frequency`.
    func start(frequency: JJYFrequency, timeZone: TimeZone) throws {
        stopInternal(deactivateSession: false)

        activeFrequency = frequency
        activeTimeZone = timeZone

        let session = AVAudioSession.sharedInstance()
        // Ignore the iPhone hardware mute/silent switch, matching navigator.audioSession.type = 'playback'.
        try session.setCategory(.playback, mode: .default, options: [])
        try? session.setPreferredSampleRate(48_000)
        try session.setActive(true)

        let engine = AVAudioEngine()
        let hwFormat = engine.outputNode.outputFormat(forBus: 0)
        let sampleRate: Double
        if hwFormat.sampleRate > 0 {
            sampleRate = hwFormat.sampleRate
        } else if session.sampleRate > 0 {
            sampleRate = session.sampleRate
        } else {
            sampleRate = 48_000
        }
        let channels: AVAudioChannelCount = hwFormat.channelCount > 0 ? min(hwFormat.channelCount, 2) : 2

        guard let renderFormat = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: channels) else {
            throw NSError(
                domain: "JJYTransmitter",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to create audio format."]
            )
        }

        let startSecond = ceil(Date().timeIntervalSince1970)
        let phaseInc = 2.0 * Double.pi * frequency.carrierHz / sampleRate
        let invSampleRate = 1.0 / sampleRate
        let calibration = calibrateWallClock()
        let packed = computePackedMinutes(around: startSecond, timeZone: timeZone)

        stateLock.withLock { state in
            state.isActive = true
            state.phaseIncrement = phaseInc
            state.invSampleRate = invSampleRate
            state.hostTicksToSeconds = self.hostTicksToSeconds
            state.hostToWallOffset = calibration
            state.outputLatency = session.outputLatency
            state.startUnixSecond = startSecond
            state.m0 = packed.0
            state.m1 = packed.1
            state.m2 = packed.2
            state.m3 = packed.3
        }

        // Real-time audio render block: captures only Sendable state (zero allocations on audio thread).
        final class PhaseBox: @unchecked Sendable {
            var value: Double = 0.0
        }
        let lock = self.stateLock
        let phaseBox = PhaseBox()
        let twoPi = 2.0 * Double.pi

        let sourceNode = AVAudioSourceNode(format: renderFormat) { isSilence, timestamp, frameCount, audioBufferList -> OSStatus in
            let snap = lock.withLock { $0 }
            let abl = UnsafeMutableAudioBufferListPointer(audioBufferList)
            let count = Int(frameCount)

            guard snap.isActive, snap.phaseIncrement > 0 else {
                isSilence.pointee = ObjCBool(true)
                for buf in abl {
                    if let mData = buf.mData {
                        memset(mData, 0, Int(buf.mDataByteSize))
                    }
                }
                return noErr
            }

            isSilence.pointee = ObjCBool(false)

            let hostTicks: UInt64 = timestamp.pointee.mFlags.contains(.hostTimeValid)
                ? timestamp.pointee.mHostTime
                : mach_absolute_time()
            let bufferWallStart = Double(hostTicks) * snap.hostTicksToSeconds
                + snap.hostToWallOffset
                + snap.outputLatency

            var phase = phaseBox.value
            for frame in 0..<count {
                let tWall = bufferWallStart + Double(frame) * snap.invSampleRate
                let sample: Float
                if tWall >= snap.startUnixSecond {
                    let secFloor = floor(tWall)
                    let frac = tWall - secFloor
                    let secInt = Int64(secFloor)
                    let minuteIndex = secInt >= 0 ? (secInt / 60) : ((secInt - 59) / 60)
                    let secInMinute = Int(secInt - minuteIndex * 60)
                    let highDuration = snap.highDuration(minuteIndex: minuteIndex, second: secInMinute)
                    sample = frac < highDuration ? Float(sin(phase)) : 0.0
                } else {
                    sample = 0.0
                }

                phase += snap.phaseIncrement
                if phase >= twoPi {
                    phase -= twoPi
                }

                for buf in abl {
                    guard let ptr = buf.mData?.assumingMemoryBound(to: Float.self) else { continue }
                    let stride = Int(buf.mNumberChannels)
                    if stride == 1 {
                        ptr[frame] = sample
                    } else {
                        let base = frame * stride
                        for ch in 0..<stride {
                            ptr[base + ch] = sample
                        }
                    }
                }
            }
            phaseBox.value = phase

            return noErr
        }

        engine.attach(sourceNode)
        engine.connect(sourceNode, to: engine.mainMixerNode, format: renderFormat)
        engine.mainMixerNode.outputVolume = 1.0
        engine.prepare()
        do {
            try engine.start()
        } catch {
            stopInternal(deactivateSession: true)
            throw error
        }

        self.engine = engine
        self.sourceNode = sourceNode
        self.isRunning = true

        installObservers(for: engine)
        startScheduleTimer()
    }

    /// Stops transmitting and releases audio resources.
    func stop() {
        stopInternal(deactivateSession: true)
    }

    private func stopInternal(deactivateSession: Bool) {
        isRunning = false
        stateLock.withLock { state in
            state.isActive = false
        }

        scheduleTimer?.invalidate()
        scheduleTimer = nil

        for token in observers {
            NotificationCenter.default.removeObserver(token)
        }
        observers.removeAll()

        if let engine {
            engine.stop()
            engine.reset()
        }
        sourceNode = nil
        engine = nil

        if deactivateSession {
            try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        }
    }

    private func startScheduleTimer() {
        let timer = Timer(timeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.refreshSchedule()
        }
        RunLoop.main.add(timer, forMode: .common)
        scheduleTimer = timer
    }

    private func refreshSchedule() {
        guard isRunning else { return }
        let now = Date().timeIntervalSince1970
        let calibration = calibrateWallClock()
        let latency = AVAudioSession.sharedInstance().outputLatency
        let packed = computePackedMinutes(around: now, timeZone: activeTimeZone)

        stateLock.withLock { state in
            state.hostToWallOffset = calibration
            state.outputLatency = latency
            state.m0 = packed.0
            state.m1 = packed.1
            state.m2 = packed.2
            state.m3 = packed.3
        }
    }

    private func installObservers(for engine: AVAudioEngine) {
        let nc = NotificationCenter.default

        let interruptionObserver = nc.addObserver(
            forName: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance(),
            queue: .main
        ) { [weak self] notification in
            guard let self, self.isRunning else { return }
            guard let raw = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
                  let type = AVAudioSession.InterruptionType(rawValue: raw) else { return }
            if type == .began {
                // Stop safely on interruptions (e.g. incoming call) so high-pitched audio never resumes unexpectedly.
                self.stop()
                self.onUnexpectedStop?()
            }
        }

        let routeObserver = nc.addObserver(
            forName: AVAudioSession.routeChangeNotification,
            object: AVAudioSession.sharedInstance(),
            queue: .main
        ) { [weak self] notification in
            guard let self, self.isRunning else { return }
            guard let raw = notification.userInfo?[AVAudioSessionRouteChangeReasonKey] as? UInt,
                  let reason = AVAudioSession.RouteChangeReason(rawValue: raw) else { return }
            if reason == .oldDeviceUnavailable {
                // Wired earphones were unplugged — stop safely instead of playing loud ultrasonic tone through speaker.
                self.stop()
                self.onUnexpectedStop?()
            }
        }

        let configObserver = nc.addObserver(
            forName: .AVAudioEngineConfigurationChange,
            object: engine,
            queue: .main
        ) { [weak self] _ in
            guard let self, self.isRunning else { return }
            let freq = self.activeFrequency
            let tz = self.activeTimeZone
            do {
                try self.start(frequency: freq, timeZone: tz)
            } catch {
                self.stop()
                self.onUnexpectedStop?()
            }
        }

        observers = [interruptionObserver, routeObserver, configObserver]
    }

    /// Brackets `Date().timeIntervalSince1970` with `mach_absolute_time()` to minimize calibration jitter.
    private func calibrateWallClock() -> Double {
        let t0 = mach_absolute_time()
        let wall = Date().timeIntervalSince1970
        let t1 = mach_absolute_time()
        let hostSeconds = (Double(t0) + Double(t1)) * 0.5 * hostTicksToSeconds
        return wall - hostSeconds
    }

    private func computePackedMinutes(
        around unixSeconds: Double,
        timeZone: TimeZone
    ) -> (PackedJJYMinute, PackedJJYMinute, PackedJJYMinute, PackedJJYMinute) {
        let secInt = Int64(floor(unixSeconds))
        let baseMinute = secInt >= 0 ? (secInt / 60) : ((secInt - 59) / 60)
        return (
            JJYCode.packedMinute(unixMinute: baseMinute, in: timeZone),
            JJYCode.packedMinute(unixMinute: baseMinute + 1, in: timeZone),
            JJYCode.packedMinute(unixMinute: baseMinute + 2, in: timeZone),
            JJYCode.packedMinute(unixMinute: baseMinute + 3, in: timeZone)
        )
    }
}
