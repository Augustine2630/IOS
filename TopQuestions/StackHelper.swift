import SwiftUI

@main
struct StackHelper: App {
    @State var signInSuccess = false
	var body: some Scene {
		WindowGroup {
            VStack {
                NavigationView {
                    TopQuestionsView(signInSuccess: $signInSuccess)
                }
            }
		}
	}
    
}
