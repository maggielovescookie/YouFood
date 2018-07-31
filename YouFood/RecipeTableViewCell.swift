//
//  RecipeTableViewCell.swift
//  YouFood
//
//  Created by ckanou on 6/28/18.
//  Copyright © 2018 Novus. All rights reserved.
//
//  Contributer: Cloud (Syou) Kanou, Maggie Xu
//

import UIKit

class RecipeTableViewCell: UITableViewCell {
    @IBOutlet weak var numLikesLabel: UILabel!
    @IBOutlet weak var recipeImageView: UIImageView!
    //MARK: Properties
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    //@IBOutlet weak var starRating: UIImage!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        recipeImageView.image = nil
    }
    
    
}

