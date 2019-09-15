//
//  Barber.swift
//  Erik Barbershop App
//
//  Created by Brian on 1/21/19.
//  Copyright © 2019 Brian. All rights reserved.
//

import Foundation
import Firebase

///Barber model.
struct Barber {
    
    ///The Id of the barber in the database.
    var barberId:String?
    ///The display name of the barber.
    var barberName: String?
    ///The barber's rating.
    var rating: String?
    ///The barber's current availability.
    var availability: String?
    ///The barber's bio.
    var bio:String?
    ///URL to the barber's image that is stored in the database.
    var barberImage:String?
    ///The barber's appointments.
    var appointments:[Appointment]?
    ///The barber's device token.
    var deviceToken:String?
    ///The barber's phone number.
    var phoneNumber:String?
    ///The barber's OAuth Token for splitting and receiving payments.
    var OAuthToken: String?
    ///The barber's referesh token used for refresihg their OAuth token.
    var refreshToken:String?
    ///the OS that the barber is using.
    var operatingSystem:String?
    ///the Id of the barbershop that the barber is associated with.
    var barbershopId: String?
    
    /**
     Main initializer. Initializes a barber object using a datasnapshot.
     
     - Parameter snapshot: Datasnapshot that will be used for initialization.
     
     - Returns: nil if initialization fails.
     
     */
    init?(snapshot: DataSnapshot) {
        
        //Barber data
        let barberData = snapshot.value as? [String:Any]
        
        //grab all the needed data that was just retrieved if there was any retrieved
        if let barberData = barberData {
            
            let barberId = snapshot.key //the barber Id is the also the name of the barber's node in the database
            let barberName = barberData["barberName"] as? String
            let availability = barberData["availability"] as? String
            let bio = barberData["bio"] as? String
            let rating = barberData["rating"] as? Double //-> not yet
            let phoneNumber = barberData["phoneNumber"] as? String
            let OAuthToken = barberData["OAuthToken"] as? String
            let refreshToken = barberData["refreshToken"] as? String
            let barbershopId = barberData["barbershopId"] as? String
            
            /* two operations to get the photo url:
             
             1. get the photo dictionary from the database
             2. get the url from that dictionary
             
             */
            let photo = barberData["photo"] as? [String:String]
            
            guard photo != nil else {
                
                return nil
                
            }
            
            let photo2 = photo!["url"]
            
            let deviceToken = barberData["deviceToken"] as? String
            
            
            guard rating != nil && barberName != nil && availability != nil && bio != nil else {
                
                return nil
                
            }
            
            //setting the information for the object
            self.barberId = barberId
            self.barberName = barberName
            //self.rating = rating -> not yet
            self.bio = bio
            self.deviceToken = deviceToken
            self.phoneNumber = (phoneNumber == nil || phoneNumber == "") ? "n/a": phoneNumber //if the phone number is nil or unavailable then set it to 'n/a'
            self.OAuthToken = OAuthToken
            self.refreshToken = refreshToken
            self.barbershopId = barbershopId
            
            //all of this is for the availability
            let week = availability?.split(separator: ",")
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE"
            
            let dateString = dateFormatter.string(from: Date())
            
            //if the phone number is available...
            if self.OAuthToken == nil || self.operatingSystem == "Android" {
                
                self.availability = "Call"
                self.rating = "🙂📞"
                
            }
            
            //if today is in the list of of days they listed, then set them as available
           else if (week?.contains(Substring(dateString)))! {
                
                self.availability = "Today"
                self.rating = "😎💈"
                
            }
                //else set them as unavailable
            else {
                
                self.availability = "Not Available Today"
                self.rating = "😢"
                
            }
            
            //set the url for the photo
            self.barberImage = photo2
            
        }
        
    }
    
    /**
     Initializes only the barberId and the barberName. Everything else is nil.
     
     - Parameter barberId: The Id of the barber in the database.
     
     - Parameter barberName: The name of the barber.
     
     - Parameter barbershopId: The Id of the barber's barbershop.
     
     */
    init(barbershopId:String,barberId:String?, barberName:String?) {
        
        self.barberId = barberId
        self.barberName = barberName
        self.barbershopId = barbershopId
        
    }
    
    /**
     Initializes everything to be nil.
     
     */
    init() {
        
        self.barberName = nil
        self.barberId = nil
        
    }
    
}
