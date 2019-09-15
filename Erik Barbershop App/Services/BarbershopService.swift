//
//  BarbershopService.swift
//  Erik Barbershop App
//
//  Created by Brian on 4/25/19.
//  Copyright © 2019 Brian. All rights reserved.
//

import Foundation
import Firebase
import CoreLocation

class BarbershopService {
    
    //MARK: - methods for the public
    
    
    /**
     Retrieves all of the barbershops that are in the databse.
     
     - Parameter completion: a closure that contains all of the barbershops that have been retrieved from the database.
     
     */
    static func getBarbershops (completion: @escaping ([Barbershop]) -> Void) {
        
        //getting a reference to the database
        let dbRef = Database.database().reference()
        
        dbRef.child("Barbershops").observeSingleEvent(of: .value) { (snapshot) in
            
            var retrievedBarbershops = [Barbershop]() //barbershop array that will be passed to the closure
            
            let snapshots = snapshot.children.allObjects as? [DataSnapshot]
            //if there are barbershops in the databse...
            if let snapshots = snapshots {
                //iterate through all of them
                for snap in snapshots {
                    //instantiate a barbershop object
                    let p = Barbershop(snapshot: snap)
                    //if this object can be instantiate it...
                    if p != nil {
                        //add it to the array
                        retrievedBarbershops.insert(p!, at: 0)
                        
                    }
                    
                }
                //pass the array to a completion closure
                completion(retrievedBarbershops)
                
            }
            
        }
        
    }
    /**
     Gets a specific barbershop.
     
     - Parameter barbershopId: the Id of the barbershop that will be retireved.
     
     - Parameter completion: a closure that contains the retrieved barbershop.
     
     */
    static func getBarbershop(barbershopId: String, completion: @escaping (Barbershop?)->Void) {
        
        //getting a reference to the databse
        let ref = Database.database().reference()
        
        ref.child("Barbershops").child(barbershopId).observeSingleEvent(of: .value) { (snapshot) in
            //if this barbershop exists
            if let barbershopData = snapshot.value as? [String:Any] {
                //instantiate a barbershop object
                var u = Barbershop(snapshot: snapshot)
                
                u?.barbershopId = snapshot.key
                u?.name = barbershopData["name"] as? String
                //send it to the completion closure
                completion(u)
                
            }
                
            else {
                //no barbershop exists
                completion(nil)
                
            }
            
        }
        
    }
    
    //MARK: - master methods
    
    static func createBarbershop(data: inout [String:Any], barbershopId: String) {
        
        data["daysOpen"] = "Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday"
        data["barbershopId"] = barbershopId
        data["photo"] = LocalStorageService.defaultPhoto()
        data["isSubscribed"] = "false"
        
        //get a database reference
        let ref = Database.database().reference()
        
        ref.child("Barbershops").child(barbershopId).setValue(data)
        
    }
    
    static func getDefaultPhoto() {
        
        //url for the default photo
        var defaultPhotoURL:String?
        
        //get a database reference
        let ref = Database.database().reference()
        
        //get the link for the default photo
        ref.child("defaultPhoto").observeSingleEvent(of: .value) { (snapshot) in
            
            defaultPhotoURL = snapshot.value as? String
            
            //sets the default photo
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
            
            let photoData = ["byId":"default","byUsername": "default", "date": dateFormatter.string(from: Date()),"url":defaultPhotoURL!]
            
            LocalStorageService.saveDefaultPhoto(photo: photoData)
            
        }
        
    }
    
    static func removeBarbershop(barbershopId: String) {
        
        //remove the barbershop
        let dbRef = Database.database().reference().child("Barbershops").child(barbershopId)
        dbRef.setValue(nil)
        
    }
    
    //MARK: - manager methods
   
    /**
     Sets the name of a specified barbershop.
     
     - Parameter barbershopId: the Id of the barbershop whise name will be set.
     
     - Parameter name: the name that will be set for the specified barbershop.
     
     */
    static func setBarbershopName(for barbershopId: String, name: String) {
        
        //get a reference to the database
        let dbRef = Database.database().reference()
        
        //set the barbershop name in thee database
        dbRef.child("Barbershops").child(barbershopId).child("name").setValue(name)
        
    }
    
    /**
     Sets the opening and closing hours of the barbershop.
     
     - Parameter barbershopId: the Id of the barbershop whose hours will be set.
     
     - Parameter hours: the hours that will be set for the barbershop.
     
     */
    static func setBarbershopHours(for barbershopId: String, hours:[String]) {
        
        //get a reference to the database
        let dbRef = Database.database().reference()
        
        //set the hours in thee database
        dbRef.child("Barbershops").child(barbershopId).child("hoursOpen").setValue(hours)
        
    }
    /**
     Sets the days that the barbershop is open.
     
     - Parameter days: the days that the barbershop will be open on.
     
     - Precondition: the days must be in this format: Monday,Tuesday,Wednesday, ....
     
     */
    static func setBarbershopDays(days: String) {
        //get a databse reference
        let dbRef = Database.database().reference().child("Barbershops").child((LocalStorageService.loadCurrentManager()?.barbershopId)!).child("daysOpen")
        
        //set the days in the database
        dbRef.setValue(days)
        
        
    }
 
    /**
     Gets the days that the barbershop is open.
     
     - Parameter barbershopId: the Id of the barbershop the days are being retrieved from.
     
     - Parameter completion: a closure that contains the days on whic the barbershop is open.
     
     */
    static func getBarbershopDays(barbershopId: String, completion: @escaping (([Substring]) -> Void )) -> Void {
        
        //make a call to the database to grab the available days
        let ref = Database.database().reference()
        
        ref.child("Barbershops").child(barbershopId).child("daysOpen").observe(.value, with: { (snapshot) in
            
            //cast the snapshot value as a dictionary
            let data = snapshot.value as? String
            
            //make sure there is actual data there
            guard data != nil else {
                
                return
                
            }
            
            //parse it appropriately and send it to the closure
            completion((data?.split(separator: ","))!)
            
        })
        
    }
  
    /**
     Sets the barbershop's prices.
     
     - Parameter barbershopId: the Id of the barbershop.
     
     - Parameter prices: a dictionary with the prices that will be set for the barbershop.
     
     */
    static func setBarbershopPrices(for barbershopId: String, prices: [[String:Int]]) {
        
        let dbRef = Database.database().reference().child("Barbershops").child((LocalStorageService.loadCurrentManager()?.barbershopId)!).child("prices")
        
        dbRef.setValue(prices)
        
        
    }
    
    /**
     Gets the barbershop's prices.
     
     - Parameter barbershopId: the Id of the barbershop.
     
     - Parameter prices: a closure that contains the barbershop's prices.
     
     */
    static func getBarbershopPrices(for barbershopId: String, completion: @escaping ([[String:Int]]) -> Void) {
        
         let dbRef = Database.database().reference().child("Barbershops").child((LocalStorageService.loadCurrentManager()?.barbershopId)!).child("prices")
        
        dbRef.observe(.value) { (snapshot) in
            
            if let data = snapshot.value as? [[String:Int]] {
                
                completion(data)
                
            }
        
        }
        
    }
    
    /**
     Sets the barbershop's address.
     
     - Parameter barbershopId: the Id of the barbershop.
     
     - Parameter address: the address that will be set for the barbershop.
     
     */
    static func setBarbershopAddress(for barbershopId: String, address: String) {
        
        let dbRef = Database.database().reference().child("Barbershops").child((LocalStorageService.loadCurrentManager()?.barbershopId)!).child("address")
        
        dbRef.setValue(address)
        
    }
    
}
