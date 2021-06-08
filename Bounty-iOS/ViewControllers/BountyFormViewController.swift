//
//  BountyFormViewController.swift
//  Bounty-iOS
//
//  Created by Runkai Zhang on 6/8/21.
//

import UIKit

import Eureka

import Firebase
import FirebaseFirestoreSwift

class BountyFormViewController: FormViewController {
    
    private let firestore = Firestore.firestore()
    private let auth = AuthenticationService()
    
    private var isValidated: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        form +++ Section("General Bounty Information")
            <<< TextRow("title") { row in
                row.add(rule: RuleRequired())
                row.add(rule: RuleMinLength(minLength: 10))
                row.add(rule: RuleMaxLength(maxLength: 35))
                row.title = "Title"
                row.placeholder = "Describe your bounty concisely"
            }
            .cellUpdate { cell, row in
                if !row.isValid {
                    cell.titleLabel?.textColor = .systemRed
                    self.isValidated = false
                }
                
                if row.section?.form?.validate() == [] {
                    self.isValidated = true
                }
            }
            <<< TextAreaRow("content") { row in
                row.placeholder = "Enter the details of your bounty here"
            }
            .cellUpdate { cell, row in
                if !row.isValid {
                    cell.textView?.textColor = .systemRed
                    self.isValidated = false
                }
                
                if row.section?.form?.validate() == [] {
                    self.isValidated = true
                }
            }
        
        // Enables the navigation accessory and stops navigation when a disabled row is encountered
        navigationOptions = RowNavigationOptions.Enabled.union(.StopDisabledRow)
        // Enables smooth scrolling on navigation to off-screen rows
        animateScroll = true
        // Leaves 20pt of space between the keyboard and the highlighted row after scrolling to an off screen row
        rowKeyboardSpacing = 20
    }
    
    @IBAction func savePressed(_ sender: Any) {
        if (isValidated) {
            upload()
        }
    }
    
    private func upload() {
        let valuesDictionary = form.values()
        let title = valuesDictionary["title"] as! String
        let content = valuesDictionary["content"] as! String
        
        let newBounty = Bounty(title: title, content: content, creator: auth.user!.uid)
        save(collection: newBounty) { docID in
            print(docID + " uploaded!")
            self.dismiss(animated: true, completion: nil)
        } error: { err in
            print(err)
        }
    }
}
