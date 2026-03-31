import SwiftUI

@main
struct SwipeTestApp: App {
	init() {
		let appearance = UINavigationBarAppearance()
		appearance.configureWithOpaqueBackground()
		appearance.backgroundColor = .systemBackground
		let proxy = UINavigationBar.appearance()
		proxy.scrollEdgeAppearance = appearance
		proxy.standardAppearance = appearance
	}

	var body: some Scene {
		WindowGroup {
			ContentView()
		}
	}
}
