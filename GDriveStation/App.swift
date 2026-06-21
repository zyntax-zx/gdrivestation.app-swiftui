import SwiftUI

@main
struct GDriveStationApp: App {
    @State private var viewModel = PlayerViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
                .onAppear {
                    viewModel.player.setup()
                }
                .onDisappear {
                    viewModel.player.cleanup()
                }
        }
    }
}
