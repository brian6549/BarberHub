//
//  BarberCell.swift
//  Erik Barbershop App
//
//  Created by Brian on 1/21/19.
//  Copyright © 2019 Brian. All rights reserved.
//

import UIKit
import SDWebImage

///The cell used for the table view in the initial view controller.
class BarberCell: UITableViewCell {
    
    
    @IBOutlet weak var barberName: UILabel!
    
    
    @IBOutlet weak var availability: UILabel!
    
    
    @IBOutlet weak var rating: UILabel!
    
    
    @IBOutlet weak var barberPicture: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        availability.adjustsFontSizeToFitWidth = true
        barberName.adjustsFontSizeToFitWidth = true
    
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    /**
     Sets the text and image of the cell.
     
     - Parameter barber: The barber object that the cell will use to display its information
     
     */
    func setBarber(_ barber:Barber, isClosed:Bool?) {
        
        barberName.text = barber.barberName
        availability.text = "Availability: " + (isClosed != nil ? "Closed": barber.availability!)
        rating.text = isClosed != nil ? "😢" : barber.rating!
        
        //download the image
        if let urlString = barber.barberImage {
            
            let url = URL(string: urlString)
            
            guard url != nil else {
                //Couldn't create url object
                return
                
            }
            
            barberPicture.sd_setImage(with: url) { (image, error, cacheType, url) in
                
                self.barberPicture.image = image
                
            }
            
        }
        
    }
    
}
