//
//  ProfileFormViewController.swift
//  Bounty-iOS
//
//  Created by Runkai Zhang on 6/6/21.
//

import UIKit

import Eureka

import Firebase

protocol ProfileFormVCDelegate {
    func didFinishProfileFormVC(controller: ProfileFormViewController)
}

class ProfileFormViewController: FormViewController {
    
    var currentBio: String?
    var currentPronoun: String?
    var currentProfile: Profile?
    var currentUser: User?
    
    var delegate: ProfileFormVCDelegate! = nil
    
    private var isValidated: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        form +++ Section("Basic Information")
            <<< TextRow("username") { row in
                row.add(rule: RuleRequired())
                row.add(rule: RuleMinLength(minLength: 4))
                row.add(rule: RuleMaxLength(maxLength: 14))
                row.validationOptions = .validatesOnChange
                row.title = "Username"
                row.placeholder = "Your new username"
                row.value = currentUser!.displayName!
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
            <<< ActionSheetRow<String>("pronoun") { row in
                row.title = "Pronoun"
                row.selectorTitle = "Select your preferred pronouns"
                row.options = [Pronoun.she.rawValue, Pronoun.he.rawValue, Pronoun.they.rawValue, Pronoun.ze.rawValue, Pronoun.NotSet.rawValue]
                row.value = currentPronoun
            }
            <<< TextAreaRow("bio") { row in
                row.add(rule: RuleMaxLength(maxLength: 45, msg: "Too long!"))
                row.validationOptions = .validatesOnChange
                row.placeholder = "Tell people something about yourself!"
                row.value = currentBio
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
        if isValidated {
            save()
        }
    }
    
    private func save() {
        let valuesDictionary = form.values()
        
        currentProfile?.username = valuesDictionary["username"] as! String
        switch valuesDictionary["pronoun"] as! String {
        case Pronoun.she.rawValue:
            currentProfile?.pronoun = .she
        case Pronoun.he.rawValue:
            currentProfile?.pronoun = .he
        case Pronoun.they.rawValue:
            currentProfile?.pronoun = .they
        case Pronoun.ze.rawValue:
            currentProfile?.pronoun = .ze
        default:
            currentProfile?.pronoun = .NotSet
        }
        currentProfile?.bio = valuesDictionary["bio"] as! String
        
        FirebaseManager().saveCurrentProfile(currentProfile!, currentUser!) { err in
            if let err = err {
                print(err)
            } else {
                self.navigationController?.popViewController(animated: true)
                self.delegate.didFinishProfileFormVC(controller: self)
            }
        }
    }
}
