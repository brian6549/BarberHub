//
//  BarbershopTableViewCell.swift
//  Erik Barbershop App
//
//  Created by Brian on 4/25/19.
//  Copyright © 2019 Brian. All rights reserved.
//

import UIKit

///The cell that shows a barbershop's information.
class BarbershopTableViewCell: UITableViewCell {

    
    @IBOutlet weak var barbershopImage: UIImageView!

    @IBOutlet weak var barberShopNameLabel: UILabel!
    
    @IBOutlet weak var barbershopAvailabilityLabel: UILabel!
    
    @IBOutlet weak var barbershopAddressLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        barbershopAddressLabel.adjustsFontSizeToFitWidth = true
        barbershopAvailabilityLabel.adjustsFontSizeToFitWidth = true
        barberShopNameLabel.adjustsFontSizeToFitWidth = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    ///Sets the cell using a barbershop object.
    func setCell(barbershop:Barbershop) {
        
        barberShopNameLabel.text = barbershop.name
        
        barbershopAddressLabel.text = barbershop.address
        
        if barbershop.isClosed != nil {
            
            barbershopAvailabilityLabel.text = "Closed"
            
        }
            
        else if barbershop.hoursOpen![0] == barbershop.hoursOpen![1] {
            
           barbershopAvailabilityLabel.text = "Open: All Day 😎"
            
        }
        
        else {
            
            //set the availability label
            let openingTime = barbershop.hoursOpen![0]
            let closingTime = barbershop.hoursOpen![1]
            
            barbershopAvailabilityLabel.text = "Open: " + (openingTime) + " - " + closingTime
        
        }
        
        if let urlString = barbershop.photo {
            
            let url = URL(string: urlString)
            
            guard url != nil else {
                //Couldn't create url object
                return
                
            }
            
            barbershopImage.sd_setImage(with: url) { (image, error, cacheType, url) in
                
                self.barbershopImage.image = image
                
            }

        }
        
    }

}
