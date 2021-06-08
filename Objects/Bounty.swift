//
//  Bounty.swift
//  Bounty-iOS
//
//  Created by Runkai Zhang on 6/8/21.
//

import Foundation
import Firebase

struct Bounty: Codable {
    var _id: String?
    let title: String
    let content: String
    let creator: String
}

extension Encodable {
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError()
        }
        return dictionary
    }
}

extension Decodable {
    /// Initialize from JSON Dictionary. Return nil on failure
    init?(dictionary value: [String:Any]){
        
        guard JSONSerialization.isValidJSONObject(value) else {
            print("Is not valid json object")
            return nil
        }
        guard let jsonData = try? JSONSerialization.data(withJSONObject: value, options: []) else {
            print("Data creation failure")
            return nil
        }
        
        guard let newValue = try? JSONDecoder().decode(Self.self, from: jsonData) else {
            print("Data creation failure 2")
            return nil
        }
        
        print(newValue)
        self = newValue
    }
}

func save(collection: Bounty, _ completion: @escaping (String) -> Void, error: @escaping (String) -> Void) {
    let db = Firestore.firestore()
    var ref: DocumentReference? = nil
    
    var data = try! collection.asDictionary()
    data["createdAt"] = FieldValue.serverTimestamp()
    
    if (collection._id != nil && collection._id != "" ) {
        ref = db.collection("bounties").document(collection._id!)
        
        ref?.setData(data) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
                completion(ref!.documentID)
            }
        }
    } else {
        ref = db.collection("bounties").addDocument(data: data) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
                completion(ref!.documentID)
            }
        }
    }
}
