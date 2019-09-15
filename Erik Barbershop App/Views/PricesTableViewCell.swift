//
//  PricesTableViewCell.swift
//  Erik Barbershop App
//
//  Created by Brian on 4/26/19.
//  Copyright © 2019 Brian. All rights reserved.
//

import UIKit

///The cell used to show the prices to show an establishment current services and prices.
class PricesTableViewCell: UITableViewCell {

    @IBOutlet weak var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        priceLabel.adjustsFontSizeToFitWidth = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    ///sets the cell with a dictionary containing the service type and price.
    func setPriceCell(with price: [String:Int]) {
        
        var theKey:String
        
        for i in price {
            
            theKey = i.key
            priceLabel.text = price[theKey] != 0 ? theKey + "($\(price[theKey]!))": theKey
        }
        
    }

}
