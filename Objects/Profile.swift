//
//  Profile.swift
//  Bounty-iOS
//
//  Created by Runkai Zhang on 6/5/21.
//

import Foundation
import Firebase

enum Pronoun: String {
    case she = "she/her/hers"
    case he = "he/him/his"
    case they = "they/them/theirs"
    case ze = "ze/hir/hir"
    case NotSet = "NotSet"
}

class Profile {
    var uid: String = ""
    var username: String = "Did not receive yet"
    private var email: String?
    var pronoun: Pronoun?
    var bio: String = ""
    private var pfpUrl: URL? = URL(string: "https://firebasestorage.googleapis.com/v0/b/bounty-eb852.appspot.com/o/profile_images%2Fdefault%2Fdefault_pfp_smol.png?alt=media&token=a4679f92-52e6-4a82-a794-81eaa3971471")
    private var badges: [String: Int] = [:]
    private var projects: [Project] = []
    
    private let storage = Storage.storage()
    private let firestore = Firestore.firestore()
    
    init(uid: String) {
        self.uid = uid
    }
    
    func getPronoun(completionHandler: @escaping (_ result: Pronoun, _ error: Error?) -> Void) {
        var err: Error?
        let group = DispatchGroup()
        group.enter()
        firestore.collection("users").document(uid).getDocument { (document, error) in
            if let document = document, document.exists {
                // let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                // print("Document data: \(dataDescription)")
                if let pronoun = document["pronoun"] as? String {
                    switch pronoun {
                    case "she/her/hers":
                        self.pronoun = .she
                    case "he/him/his":
                        self.pronoun = .he
                    case "they/them/theirs":
                        self.pronoun = .they
                    case "ze/hir/hir":
                        self.pronoun = .ze
                    default:
                        self.pronoun = .NotSet
                    }
                } else {
                    self.pronoun = .NotSet
                }
            } else {
                // print("Document does not exist")
                self.pronoun = .NotSet
                err = error
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            completionHandler(self.pronoun!, err)
        }
    }
    
    func getPfpUrl(completionHandler: @escaping (_ result: URL, _ error: Error?) -> Void) {
        var err: Error?
        let group = DispatchGroup()
        let profileImgReference = storage.reference().child("profile_images").child(uid).child("\(uid).png")
        group.enter()
        profileImgReference.downloadURL { url, error in
            if let error = error {
                print("Error!")
                print(error)
                err = error
            } else {
                self.pfpUrl = url
            }
            
            group.leave()
        }
        
        group.notify(queue: .main) {
            completionHandler(self.pfpUrl!, err)
        }
    }
    
    func getBio(completionHandler: @escaping (_ result: String, _ error: Error?) -> Void) {
        var err: Error?
        let group = DispatchGroup()
        group.enter()
        firestore.collection("users").document(uid).getDocument { (document, error) in
            if let document = document, document.exists {
                // let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                // print("Document data: \(dataDescription)")
                if let doc = document["bio"] as? String {
                    self.bio = doc
                } else {
                    self.bio = ""
                }
            } else {
                // print("Document does not exist")
                err = error
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            completionHandler(self.bio, err)
        }
    }
}
