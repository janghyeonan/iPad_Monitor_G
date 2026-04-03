import SwiftUI

@main
struct iPad_Monitor_GApp: App {
    @StateObject private var env = AppEnvironment()

    var body: some Scene {
        WindowGroup {
            PreviewView(viewModel: env.makePreviewViewModel())
        }
    }
}
