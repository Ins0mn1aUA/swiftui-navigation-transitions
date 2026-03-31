import SwiftUI
import SwiftUINavigationTransitions

struct ContentView: View {
	var body: some View {
		NavigationStack {
			ListView(title: "Root", color: .blue)
		}
		.navigationTransition(.slide, interactivity: .pan)
	}
}

struct ListView: View {
	let title: String
	let color: Color

	private let destinations: [(String, Color)] = [
		("Red Screen", .red),
		("Green Screen", .green),
		("Orange Screen", .orange),
		("Purple Screen", .purple),
		("Teal Screen", .teal),
	]

	var body: some View {
		List(destinations, id: \.0) { dest in
			NavigationLink(dest.0) {
				ListView(title: dest.0, color: dest.1)
			}
		}
		.listStyle(.plain)
		.navigationTitle(title)
		.background(color.opacity(0.15))
	}
}
