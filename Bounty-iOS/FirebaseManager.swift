//
//  FirebaseManager.swift
//  Bounty-iOS
//
//  Created by Runkai Zhang on 6/3/21.
//

import Foundation
import Firebase

class FirebaseManager {

    private let firestore = Firestore.firestore()
    private let storage = Storage.storage()
    
    func get(_ collection: String) {
        firestore.collection(collection).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                }
            }
        }
    }
    
    func uploadCurrentProfile(_ user: User) {
        firestore.collection("users").document(user.uid).updateData([
            "username": user.displayName!,
            "email": user.email!
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
    func saveCurrentProfile(_ profile: Profile, _ user: User, completionHandler: @escaping (_ error: Error?) -> Void) {
        let request = user.createProfileChangeRequest()
        request.displayName = profile.username
        request.commitChanges { error in
            if let error = error {
                print(error)
                completionHandler(error)
            }
        }
        
        firestore.collection("users").document(profile.uid).updateData([
            "pronoun": profile.pronoun!.rawValue,
            "bio": profile.bio
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
                completionHandler(err)
            } else {
                print("Document successfully written!")
                completionHandler(err)
            }
        }
    }
}
