//
//  Barbershop.swift
//  Erik Barbershop App
//
//  Created by Brian on 4/25/19.
//  Copyright © 2019 Brian. All rights reserved.
//

import Foundation
import Firebase
import CoreLocation

///The model that is used to represent an establishment.
struct Barbershop {
    
    ///The name of the establishment.
    var name:String?
    ///The Id of the establishment.
    var barbershopId:String?
    ///The days that this establishment is open.
    var daysOpen:String?
    ///The hours that this establishment is open.
    var hoursOpen:[String]?
    ///The address of the establishment.
    var address:String? //format: 1 Infinite Loop, Cupertino, CA 95014
    ///The photo URL of the establishment.
    var photo:String?
    ///The establishment's current services and prices.
    var prices:[[String:Int]]?
    ///The establishment's CLLocation.
    var location:CLLocation?
    ///THe barbershop manager information.
    var manager:[String:String]?
    ///The type of establishment that this is.
    var establishmentType:String?
    ///Boolean that determined wether or not a barbershop is closed today.
    var isClosed: Bool?
    ///String that tells wether or not the barbershop is paying monthly for the service.
    var isSubscribed:String?
    
    ///Failable initializer that uses a snapshot to initialize the object.
    init?(snapshot: DataSnapshot) {
        
        //get and parse the barbershop info if there is ones
        let barbershopData = snapshot.value as? [String:Any]
        
        if let barbershopData = barbershopData {
            
            let barbershopId = snapshot.key
            let name = barbershopData["name"] as? String
            let daysOpen = barbershopData["daysOpen"] as? String
            let hoursOpen = barbershopData["hoursOpen"] as? [String]
            let address = barbershopData["address"] as? String
            let prices = barbershopData["prices"] as? [[String:Int]]
            let manager = barbershopData["manager"] as? [String:String]
            let establishmentType = barbershopData["establishmentType"] as? String
            let isSubscribed = barbershopData["isSubscribed"] as? String
            
            
            /* two operations to get the photo url:
             
             1. get the photo dictionary from the database
             2. get the url from that dictionary
             
             */
            
            let photo = barbershopData["photo"] as? [String:String]
            
            guard photo != nil else {
                
                return nil
                
            }
            
            let photo2 = photo!["url"]
            
            
            guard name != nil && daysOpen != nil && hoursOpen != nil && address != nil
                && prices != nil else {
                
                return nil //initialization failed
                
            }
            
            self.barbershopId = barbershopId
            self.name = name
            self.daysOpen = daysOpen
            self.hoursOpen = hoursOpen
            self.address = address
            self.photo = photo2
            self.prices = prices
            self.manager = manager
            self.establishmentType = establishmentType
            self.isSubscribed = isSubscribed
            
            
            //all of this is for the availability
            let week = daysOpen?.split(separator: ",")
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE"
            
            let dateString = dateFormatter.string(from: Date())
            
            if !((week?.contains(Substring(dateString)))!) {
                
                self.isClosed = true
              
            }
        
        }
        
    }
    
    ///Regular init.
    init() {}
    
}
