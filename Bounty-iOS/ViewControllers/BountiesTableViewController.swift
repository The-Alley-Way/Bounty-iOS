//
//  BountiesTableViewController.swift
//  Bounty-iOS
//
//  Created by Runkai Zhang on 6/8/21.
//

import UIKit
import FirebaseFirestore
import SkeletonView

class BountiesTableViewController: UITableViewController {
    
    var bounties: [Bounty] = [Bounty]()
    var documents = [QueryDocumentSnapshot]()
    
    let db = Firestore.firestore()
    
    var query: Query!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        query = db.collection("bounties")
            .order(by: "createdAt", descending: false)
            .limit(to: 15)
        
        getData()
    }
    
    func getData() {
        query.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                querySnapshot!.documents.forEach({ (document) in
                    let data = document.data()
                    
                    //Setup your data model
                    let newBounty = Bounty(_id: document.documentID, title: data["title"] as! String, content: data["content"] as! String, creator: data["creator"] as! String)
                    self.bounties.append(newBounty)
                    self.documents.append(document)
                })
                self.tableView.reloadData()
            }
        }
    }
    
    func paginate() {
        //This line is the main pagination code.
        //Firestore allows you to fetch document from the last queryDocument
        query = query.start(afterDocument: documents.last!)
        getData()
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bounties.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bountyCell", for: indexPath) as! BountyTableViewCell
        let bounty = bounties[indexPath.row]
        
        // Configure the cell...
        cell.titleLabel.text = bounty.title
        cell.contentTextView.text = bounty.content
        cell.titleLabel.hideSkeleton()
        cell.contentTextView.hideSkeleton()
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Trigger pagination when scrolled to last cell
        // Feel free to adjust when you want pagination to be triggered
        if (indexPath.row == bounties.count - 1) && (indexPath.count >= 15) {
            paginate()
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
