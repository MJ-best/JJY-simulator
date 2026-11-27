import SwiftUI
import UIKit

@MainActor
final class SimulatorViewModel: ObservableObject {
    @Published var selectedZoneID: String
    @Published var frequency: JJYFrequency = .khz40
    @Published private(set) var isTransmitting: Bool = false
    @Published private(set) var audioErrorMessage: String?

    private let transmitter = JJYTransmitter()

    init() {
        self.selectedZoneID = TimeZone.current.identifier
        self.transmitter.onUnexpectedStop = { [weak self] in
            Task { @MainActor [weak self] in
                self?.handleUnexpectedStop()
            }
        }
    }

    var deviceZoneID: String {
        TimeZone.current.identifier
    }

    var selectedTimeZone: TimeZone {
        TimeZone(identifier: selectedZoneID) ?? .current
    }

    var selectedCity: City? {
        CityCatalog.city(for: selectedZoneID)
    }

    func selectZone(_ zoneID: String) {
        guard zoneID != selectedZoneID else { return }
        selectedZoneID = zoneID
        if isTransmitting {
            restartTransmission()
        }
    }

    func selectFrequency(_ newFrequency: JJYFrequency) {
        guard newFrequency != frequency else { return }
        frequency = newFrequency
        if isTransmitting {
            restartTransmission()
        }
    }

    func toggleTransmission() {
        if isTransmitting {
            stop()
        } else {
            start()
        }
    }

    func start() {
        audioErrorMessage = nil
        do {
            try transmitter.start(frequency: frequency, timeZone: selectedTimeZone)
            isTransmitting = true
            UIApplication.shared.isIdleTimerDisabled = true
        } catch {
            isTransmitting = false
            UIApplication.shared.isIdleTimerDisabled = false
            audioErrorMessage = error.localizedDescription
        }
    }

    func stop() {
        transmitter.stop()
        isTransmitting = false
        UIApplication.shared.isIdleTimerDisabled = false
    }

    func handleScenePhaseChange(_ phase: ScenePhase) {
        if phase == .background && isTransmitting {
            stop()
        }
    }

    private func restartTransmission() {
        stop()
        start()
    }

    private func handleUnexpectedStop() {
        isTransmitting = false
        UIApplication.shared.isIdleTimerDisabled = false
    }
}
