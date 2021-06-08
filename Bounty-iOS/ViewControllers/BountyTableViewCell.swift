//
//  BountyTableViewCell.swift
//  Bounty-iOS
//
//  Created by Runkai Zhang on 6/8/21.
//

import UIKit
import SkeletonView

class BountyTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        titleLabel.showAnimatedGradientSkeleton()
        contentTextView.showAnimatedGradientSkeleton()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
