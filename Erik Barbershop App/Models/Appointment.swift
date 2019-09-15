//
//  Appointments.swift
//  Erik Barbershop App
//
//  Created by Brian on 1/21/19.
//  Copyright © 2019 Brian. All rights reserved.
//

import Foundation
import Firebase


//TODO: - add amount and possibly a tender.

///Appointment model.
struct Appointment {
    
    ///The name of the person that made the appointment.
    var name: String?
    ///This time is used for sorting in table views.
    var time:String?
    ///This is then time that everyone will actually see.
    var timeToDisplay:String?
    ///This date is used for sorting in table views.(firebase doesn't see this)
    var timeToDate: Date?
    ///The appointmentId.
    var appointmentId: String?
    ///The barberId of the barber that the appointment was made with.
    var barberId: String?
    ///The barber's device token.
    var barberToken: String?
    ///The barber's name.
    var barberName: String?
    ///The user's device token.
    var userToken: String?
    ///The transaction Id that will be used to recover a refund for the appointment if necessary.
    var transactionId:String?
    ///The transaction Id that will be used to recover a refund for the appointment if necessary.
    var locationId:String?
    ///The amount that was paid for the haircut.
    var amount:Double?
    ///The id of the tender used.
    var tenderId:String?
    ///The type of haircut that was paid for.
    var haircutType:String?
    ///The date that the appointment was created on.
    var createdOn: String?
    ///The barber's phone number.
    var contactNumber:String?
    ///The address of the barbershop that the appointment was made in.
    var barbershopAddress:String?
    ///The Id of the barbershop that the appointment was made in.
    var barbershopId:String?
   ///The name of the barbershop that the appointment will take place in.
    var barbershopName:String?
    
    /**
     Intializes everything to nil.
     
     */
    init() {
        
        self.name = nil
        self.time = nil
        self.appointmentId = nil
        self.barberId = nil
        self.barberToken = nil
        self.userToken = nil
        
        
    }
    
    /**
     Main initializer. Initializes an appointment object using a datasnapshot.
     
     - Parameter snapshot: Datasnapshot that will be used for initialization.
     
     - Returns: nil if initialization fails.
     
     */
    init?(snapshot: DataSnapshot) {
        
        //cast the snapshot value as a dictionary
        
        let appointmentData = snapshot.value as? [String:Any]
        
        //if the cast was successful...
        if let appointmentData = appointmentData {
            
            //initialize everything
            let name = appointmentData["name"] as? String
            let time = appointmentData["time"] as? String
            let timeToDisplay = appointmentData["timeToDisplay"] as? String
            let appointmentId = appointmentData["appointmentId"] as? String
            let barberId = appointmentData["barberId"] as? String
            let barberToken = appointmentData["barberToken"] as? String
            let  barberName = appointmentData["barberName"] as? String
            let userToken = appointmentData["userToken"] as? String
            let transactionId = appointmentData["transactionId"] as? String
            let amount = appointmentData["amount"] as? Double
            let locationId = appointmentData["locationId"] as? String
            let haircutType = appointmentData["haircutType"] as? String
            let tenderId = appointmentData["tenderId"] as? String
            let createdOn = appointmentData["createdOn"] as? String
            let contactNumber = appointmentData["contactNumber"] as? String
            let address = appointmentData["barbershopAddress"] as? String
            let barbershopId = appointmentData["barbershopId"] as? String
            let barbershopName = appointmentData["barbershopName"] as? String
            
            //make sure the appointment is a valid one before trying to initialize, else return nil
            guard name != nil  && time != nil else {
                
                return nil
                
            }
            //some of these will be for the user
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy, HH:mm"
            
            self.name = name
            self.time = time
            self.timeToDate = dateFormatter.date(from: time!)
            self.appointmentId = appointmentId
            self.barberId = barberId
            self.barberToken = barberToken
            self.barberName = barberName
            self.userToken = userToken
            self.timeToDisplay = timeToDisplay
            self.transactionId = transactionId
            self.amount = amount
            self.locationId = locationId
            self.tenderId = tenderId
            self.haircutType = haircutType
            self.createdOn = createdOn
            self.contactNumber = contactNumber
            self.barbershopAddress = address
            self.barbershopId = barbershopId
            self.barbershopName = barbershopName
           
        }
      
        
    }
    
}

