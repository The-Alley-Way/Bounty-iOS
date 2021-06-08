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
    
    let tagger = NSLinguisticTagger(tagSchemes:[.language], options: 0)
    let options: NSLinguisticTagger.Options = [.omitPunctuation, .omitWhitespace, .joinNames]
    
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
    
    func determineLanguage(for text: String) -> String? {
        tagger.string = text
        let language = tagger.dominantLanguage
        return language
    }
    
    @IBAction func savePressed(_ sender: Any) {
        if (isValidated) {
            let valuesDictionary = form.values()
            let content = valuesDictionary["content"] as! String
            
            if determineLanguage(for: content) != "en" {
                let alert = UIAlertController(title: "Just a sec!", message: "It seems like your bounty was not written in English. That is completely fine, however, you might miss out on some non-essential features.", preferredStyle: .alert)
                let uploadAction = UIAlertAction(title: "Upload", style: .default) { action in
                    self.upload()
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in }
                alert.addAction(uploadAction)
                alert.addAction(cancelAction)

                self.navigationController?.popViewController(animated: true)
            } else {
                upload()
            }
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
