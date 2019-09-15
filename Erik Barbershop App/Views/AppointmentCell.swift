//
//  AppointmentCell.swift
//  Erik Barbershop App
//
//  Created by Brian on 1/27/19.
//  Copyright © 2019 Brian. All rights reserved.
//

import UIKit
import SDWebImage

///Cell that will be used for the appointment view controllers.
class AppointmentCell: UITableViewCell {
    
    
    @IBOutlet weak var nameLabel: UILabel!
    
    
    @IBOutlet weak var dateLabel: UILabel!
    
    
    @IBOutlet weak var haircutTypeLabel: UILabel!
    
    
    @IBOutlet weak var barbershopLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        nameLabel.adjustsFontSizeToFitWidth = true
        dateLabel.adjustsFontSizeToFitWidth = true
        haircutTypeLabel.adjustsFontSizeToFitWidth = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
     
    }
    
    /**
     Sets the text and image of the cell for the barber's appointment view controller.
     
     - Parameter appointmetnt: The appointment object that the cell will use to display its information.
     
     */
    func setAppointment(_ appointment:Appointment) {
        
        nameLabel.text = appointment.name
         haircutTypeLabel.text = "Service Type: \(appointment.haircutType!)"
        dateLabel.text = appointment.timeToDisplay
        
    }
    
    /**
     Sets the text and image of the cell for the user's appointment view controller.
     
     - Parameter appointmetnt: The appointment object that the cell will use to display its information.
     
     */
    func setAppointmentForUser(_ appointment:Appointment) {
        
        barbershopLabel.adjustsFontSizeToFitWidth = true
        nameLabel.text = appointment.barberName
        haircutTypeLabel.text = "Service Type: \(appointment.haircutType!)"
        dateLabel.text = "On: " + appointment.timeToDisplay!
        barbershopLabel.text = "At: \(appointment.barbershopName!)"
        
    }
    
}
