//
//  DayTableViewCell.swift
//  Erik Barbershop App
//
//  Created by Brian on 2/5/19.
//  Copyright © 2019 Brian. All rights reserved.
//

import UIKit

///The cell that is used to display a day in the set availability view controller.
class DayTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var dayLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    /**
     Sets the text in a cell.
     
     - Parameter text: The text that will be set for the cell.
     
     */
    func setCell (text: String?) {
        
        dayLabel.text = text
        
    }
    
}
