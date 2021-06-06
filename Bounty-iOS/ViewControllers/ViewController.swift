//
//  ViewController.swift
//  Bounty-iOS
//
//  Created by Runkai Zhang on 6/3/21.
//

import UIKit

import SPPermissions

import Firebase
import FirebaseUI

class ViewController: UIViewController, FUIAuthDelegate {

    let authUI = FUIAuth.defaultAuthUI()!

    var handle: AuthStateDidChangeListenerHandle?

    let manager = FirebaseManager()
    
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var accessButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        authUI.delegate = self

        let providers: [FUIAuthProvider] = [
            FUIEmailAuth()
        ]

        authUI.providers = providers
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        handle = Auth.auth().addStateDidChangeListener { (_, user) in
            if (user != nil) {
              // User is signed in.
                self.signInButton.isHidden = true
                self.logOutButton.isHidden = false
                self.accessButton.isHidden = false
            } else {
              // No user is signed in.
                self.signInButton.isHidden = false
                self.logOutButton.isHidden = true
                self.accessButton.isHidden = true
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
      }

    @IBAction func signIn(_ sender: Any) {
        let authViewController = authUI.authViewController()
        self.present(authViewController, animated: true, completion: nil)
    }

    @IBAction func logOut(_ sender: Any) {
        do {
            _ = try authUI.signOut()
        } catch {
            print(error)
        }
    }
    
    @IBAction func checkPressed(_ sender: Any) {
        let permissions: [SPPermissions.Permission] = [.camera, .notification, .photoLibrary]
        let controller = SPPermissions.list(permissions)
        controller.present(on: self)
    }

    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        // handle user and error as necessary
        print(error ?? "No error signing in")
        
        if let user = user {
            // Add a new document in collection "cities"
            manager.uploadCurrentProfile(user)
        }
    }
}
