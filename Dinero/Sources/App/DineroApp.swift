import SwiftUI

@main
struct DineroApp: App {
    @State private var store = ExpenseStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
        }
    }
}
