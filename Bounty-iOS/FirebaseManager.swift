//
//  FirebaseManager.swift
//  Bounty-iOS
//
//  Created by Runkai Zhang on 6/3/21.
//

import Foundation
import Firebase

class FirebaseManger {
    
    private let db = Firestore.firestore()
    
    func getFirestore(_ collection: String) {
        db.collection(collection).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                }
            }
        }
    }
}
