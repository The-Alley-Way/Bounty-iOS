//
//  ViewController.swift
//  Bounty-iOS
//
//  Created by Runkai Zhang on 6/3/21.
//

import UIKit

class ViewController: UIViewController {
    
    let fm = FirebaseManger()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        fm.getFirestore("users")
    }


}

