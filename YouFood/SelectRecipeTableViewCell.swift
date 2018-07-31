//
//  SelectRecipeTableViewCell.swift
//
//
//  Created by ckanou on 7/24/18.
//
//  Contributers: Cloud Kanou
//
//  Not much to say here. Just setting up the label outlets so they reflect the title and author
//  of the recipes in the select recipe table view controller

import UIKit

class SelectRecipeTableViewCell: UITableViewCell {
    
    //MARK: Properties
    
    @IBOutlet weak var titleLabel2: UILabel!
    @IBOutlet weak var authorLabel2: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

