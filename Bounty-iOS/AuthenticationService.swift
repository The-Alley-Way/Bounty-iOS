import Foundation
import Firebase

// 1
class AuthenticationService: ObservableObject {
    var user: User?
    private var authenticationStateHandler: AuthStateDidChangeListenerHandle?
    
    init() {
        addListeners()
    }
    
    static func signIn() {
        if Auth.auth().currentUser == nil {
            Auth.auth().signInAnonymously()
        }
    }
    
    private func addListeners() {
        if let handle = authenticationStateHandler {
            Auth.auth().removeStateDidChangeListener(handle)
        }
        
        authenticationStateHandler = Auth.auth()
            .addStateDidChangeListener { _, user in
                self.user = user
            }
    }
}
