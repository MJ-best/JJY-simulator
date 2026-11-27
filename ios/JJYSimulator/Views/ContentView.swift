import SwiftUI

/// Root universal layout adapting cleanly between iPhone (single column) and iPad (full-width map + two columns).
struct ContentView: View {
    @StateObject private var viewModel = SimulatorViewModel()
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.scenePhase) private var scenePhase

    private var isRegularWidth: Bool {
        horizontalSizeClass == .regular
    }

    var body: some View {
        ZStack {
            Theme.bg(for: colorScheme)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header

                    WorldMapCard(
                        selectedZoneID: viewModel.selectedZoneID,
                        onSelectZone: { viewModel.selectZone($0) }
                    )

                    if isRegularWidth {
                        HStack(alignment: .top, spacing: 16) {
                            VStack(spacing: 16) {
                                clockCard
                                transmitterCard
                            }
                            .frame(maxWidth: .infinity)

                            VStack(spacing: 16) {
                                HowToUseCard()
                                FAQCard()
                            }
                            .frame(maxWidth: .infinity)
                        }
                    } else {
                        clockCard
                        transmitterCard
                        HowToUseCard()
                        FAQCard()
                    }
                }
                .padding(16)
                .frame(maxWidth: isRegularWidth ? 1040 : 704)
                .frame(maxWidth: .infinity)
            }
        }
        .onChange(of: scenePhase) { newPhase in
            viewModel.handleScenePhaseChange(newPhase)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("app.title")
                .font(.title2.weight(.bold))
                .foregroundStyle(Theme.fg(for: colorScheme))

            Text("app.subtitle")
                .font(.subheadline)
                .foregroundStyle(Theme.muted(for: colorScheme))
        }
        .padding(.top, 4)
    }

    private var clockCard: some View {
        ClockCard(
            selectedZoneID: viewModel.selectedZoneID,
            deviceZoneID: viewModel.deviceZoneID,
            onSelectZone: { viewModel.selectZone($0) }
        )
    }

    private var transmitterCard: some View {
        TransmitterCard(
            frequency: viewModel.frequency,
            isTransmitting: viewModel.isTransmitting,
            timeZone: viewModel.selectedTimeZone,
            errorMessage: viewModel.audioErrorMessage,
            onSelectFrequency: { viewModel.selectFrequency($0) },
            onToggleTransmission: { viewModel.toggleTransmission() }
        )
    }
}

#Preview {
    ContentView()
}
