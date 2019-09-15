//
//  BarberService.swift
//  Erik Barbershop App
//
//  Created by Brian on 1/21/19.
//  Copyright © 2019 Brian. All rights reserved.
//

import Foundation
import Firebase

//TODO: - if the barber gets deleted but still has appointments, cancel all of them first

///Core component #1 of the app. Manages barbers in the database.
class BarberService {
    
    
    //MARK: - for authentication
    
    /**
     Gets a registered barber profile if there is one.
     
     - Parameter barbershopId: The Id of the barber's associated barbershop.
     - Parameter barberId: The Id associated with the profile.
     - Parameter completion: A closure with a Barber object created from the details of the retrieved profile or nil if there is none.
     
     */
    static func getBarberProfile(barbershopId: String, barberId: String, completion: @escaping (Barber?) -> Void) -> Void {
        
        //get a database reference
        let ref = Database.database().reference()
        
        //try to retrieve the profile for passed in barberId
        ref.child("Barbershops").child(barbershopId).child("Barbers").child(barberId).observeSingleEvent(of: .value) { (snapshot) in
            
            //check the returned snapshot value to see if there is a profile
            if let userProfileData = snapshot.value as? [String:Any] {
                
                //this means there is a profile
                //create a barber with the profile details
                var b = Barber(snapshot: snapshot)
                b?.barberId = snapshot.key
                b?.barberName = userProfileData["barberName"] as? String
                b?.barbershopId = userProfileData["barbershopId"] as? String
                
                //pass into completion closure
                completion(b)
                
            }
                
            else {
                //this means there wasn't a profile
                //return nil
                completion(nil)
                
            }
            
            
        } //end of closure
        
    } //end of function
    
    //MARK: - miscellaneous
    
    /**
     Checks if the barber profile still exists.
     
     - Parameter barbershopId: The Id of the barber's associated barbershop.
     
     - Parameter barberId: The Id of the profile to be observed.
     
     - Parameter completion: A closure with a Barber object created from the details of the retrieved profile or nil if there is none.
     
     */
    static func observeBarberProfile(barbershopId: String, barberId: String, completion: @escaping (Barber?) -> Void) -> Void {
        
        //get a database reference
        let ref = Database.database().reference()
        //try to retrieve the profile for passed in userid
        ref.child("Barbershops").child(barbershopId).child("Barbers").child(barberId).observe(.value) { (snapshot) in //this line is what differentiates this function from getBarberProfile
            
            //check the returned snapshot value to see if there is a profile
            if let userProfileData = snapshot.value as? [String:Any] {
                
                //this means there is a profile
                //create a barber with the profile details
                var u = Barber(snapshot: snapshot)
                u?.barberId = snapshot.key
                u?.barberName = userProfileData["barberName"] as? String
                
                
                //pass into completion closure
                completion(u)
                
            }
                
            else {
                //this means there wasn't a profile
                //return nil
                completion(nil)
                
            }
            
        } //end of closure
        
    } //end of function
    
    /**
     Sets the device token for the specified barber.
     
     - Parameter barberId: The barber ID that the token will be sent to.
     
     - Parameter barbershopId: The Id of the barber's associated barbershop.
     
     - Parameter token: The device token that will be set for the barber ID.
     
     */
    static func setToken(for barberId: String, in barbershopId: String, token: String) {
        
        //get a reference to the database location
        let dbRef = Database.database().reference().child("Barbershops").child(barbershopId).child("Barbers").child(barberId).child("deviceToken")
        
        
        //set the token in the database
        dbRef.setValue(token)
        
        
    }
    
    
    //MARK: - for the initial table view
    
    /**
     Grabs all of the barbers that are currently in the database.
     
     - Parameter barbershopId: The Id of the barbershop that the barbers will be retrieved from.
     
     - Parameter completion: A closure with an array of barber objects created from the retrieved barber information.
     
     */
    static func getBarbers(for barbershopId:String, completion: @escaping (([Barber]) -> Void)) -> Void {
        
        //getting a reference to the database
        let dbRef = Database.database().reference()
        
        //make the database call
        dbRef.child("Barbershops").child(barbershopId).child("Barbers").observeSingleEvent(of: .value) { (snapshot) in
            
            //array that will be passed into the closure
            var retrievedBarbers = [Barber]()
            
            //get the list of snapshots
            let snapshots = snapshot.children.allObjects as? [DataSnapshot]
            
            if let snapshots = snapshots {
                
                //loop through each snapshot and parse out the barbers
                
                for snap in snapshots {
                    
                    //try to create a barber from a snapshot
                    let p = Barber(snapshot: snap)
                    
                    //if successful, then add it to the array
                    if p != nil {
                        
                        retrievedBarbers.insert(p!, at: 0)
                        
                    }
                    
                }
                
            }
            
            //after parsing the snapshots, call the completion closure
            completion(retrievedBarbers)
            
        }
        
    }
    
    
    // MARK: - for the set availability view controller
    
    /**
     Gets the days that the barber is available.
     
     - Parameter barberId: The barberId that the dates will be grabbed from.
     
     - Parameter barbershopId: The Id of the barber's associated barbershop.
     
     - Parameter completion: A closure with the days that the barber is available.
     
     */
    static func getDays(barberId: String, barbershopId: String, completion: @escaping (([Substring]) -> Void )) -> Void {
        
        //make a call to the database to grab the available days
        let ref = Database.database().reference()
        
        ref.child("Barbershops").child(barbershopId).child("Barbers").child(barberId).observe(.value, with: { (snapshot) in
            
            //cast the snapshot value as a dictionary
            let data = snapshot.value as? [String:Any]
            
            //make sure there is actual data there
            guard data != nil else {
                
                return
                
            }
            
            //get the days that the barber is available
            let week = data!["availability"] as? String
            
            //parse it appropriately and send it to the closure
            completion((week?.split(separator: ","))!)
            
        })
        
    }
    
    /**
     
     Sets the days that a barber is available.
     
     - Parameter days: The list of days that the barber is available.
     
     - Precondition: The List of days must be in this format: Monday,Tuesday,Wednesday,Thursday,Friday and the barber must be logged in.
     
     
     */
    static func setDays(days: String) {
        
        let dbRef = Database.database().reference().child("Barbershops").child((LocalStorageService.loadCurrentBarber()?.barbershopId)!).child("Barbers").child((LocalStorageService.loadCurrentBarber()?.barberId)!).child("availability")
        
        //set the days in the database
        dbRef.setValue(days)
        
        
    }
    
    //MARK: - for the edit profile view controller
    
    /**
     
     Updates the name of the barber.
     
     - Parameter barberId: The id of the barber in the database
     
     - Parameter barbershopId: The Id of the barber's associated barbershop.
     
     - Parameter name: The new name that will be set for the barber
     
     
     
     */
    static func setName(for barberId: String, in barbershopId: String, name: String )  {
        
        
        //get a reference to the database
        let dbRef = Database.database().reference()
        
        //set the barberName in the database
        dbRef.child("Barbershops").child(barbershopId).child("Barbers").child(barberId).child("barberName").setValue(name)
        
        
    }
    
    /**
     
     Updates the bio of the barber.
     
     - Parameter barberId: The id of the barber in the database.
     
     - Parameter barbershopId: The Id of the barber's associated barbershop.
     
     - Parameter bio: The new bio that will be set for the barber.
     
     
     */
    static func setBio(for barberId: String, in barbershopId:String, bio: String ) {
        
        //get a reference to the database
        let dbRef = Database.database().reference()
        
        //set the bio in the database
        dbRef.child("Barbershops").child(barbershopId).child("Barbers").child(barberId).child("bio").setValue(bio)
        
    }
    
    /**
     
     Updates barber's phone number.
     
     - Parameter barberId: The id of the barber in the database.
     
     - Parameter barbershopId: The Id of the barber's associated barbershop.
     
     - Parameter phoneNumber: The phone number that will be set for the barber.
     
     */
    static func setBarberPhoneNumber(for barberId: String, in barbershopId: String, phoneNumber: String) {
    
        //get a reference to the database
        let dbRef = Database.database().reference()
        
        //set the bio in the database
        dbRef.child("Barbershops").child(barbershopId).child("Barbers").child(barberId).child("phoneNumber").setValue(phoneNumber)
    
    }
    
    //MARK: - manager methods
    
    /**
     Creates a barber node in the database with information from the parameters and other default information.
     
     - Parameter barbershopId: The Id of the barber's associated barbershop.
     
     - Parameter barberId: The barberId of the barber.
     
     - Parameter completion: A closure with an object for the barber that was just created or nil if an error occurs while making the object.
     
     */
    static func createBarberProfile(in barbershopId: String,barberId: String, barberName: String, phoneNumber: String, operatingSystem:String, completion: @escaping (Barber?) -> Void) -> Void {
        
        var establishmentType:String?
        
        if let manager = LocalStorageService.loadCurrentManager() {
            
            establishmentType = manager.establishmentType
            
        }
            
        else if let barbershop = LocalStorageService.loadCurrentBarbershop() {
            
            establishmentType = barbershop.establishmentType
            
        }
        
        guard establishmentType != nil else {
            
            return
            
        }
        
        //data that will be put into the new node.
        let barberProfileData:[String:Any] = ["availability": "Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday","barberName": barberName, "bio": (establishmentType == "Barbershop" ? "I Love Giving Good Haircuts :)" : "I Love Making People Look More Beautiful :)"), "deviceToken": "", "rating": 0.0,"phoneNumber": phoneNumber ,"operatingSystem":operatingSystem,"barbershopId":barbershopId]
        
        //url for the default photo
        var defaultPhotoURL:String?
        
        //get a database reference
        let ref = Database.database().reference()
        
        //get the link for the default photo
        ref.child("defaultPhoto").observeSingleEvent(of: .value) { (snapshot) in
            
            defaultPhotoURL = snapshot.value as? String
            
        }
        
        //create a profile for the user id
        ref.child("Barbershops").child(barbershopId).child("Barbers").child(barberId).setValue(barberProfileData) { (error, ref) in
            
            if error != nil {
                
                //there was an error
                completion(nil)
                
            }
                
            else {
                
                let b = Barber(barbershopId: barbershopId,barberId: barberId, barberName: barberName)
                
                //sets the default photo
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
                
                let photoData = ["byId":barberId,"byUsername": barberName, "date": dateFormatter.string(from: Date()),"url":defaultPhotoURL!]
                
                ref.child("photo").setValue(photoData)
                
                completion(b)
                
            }
            
        }
        
    }
    
    /**
     Deletes a barber and the associated account from the database.
     
     - Parameter barbershopId: The Id of the barber's associated barbershop.
     
     - Parameter barberId: The barberId of the barber that will be deleted.
     
     */
    static func deleteBarber(in barbershopId: String, with barberId: String) {
        
        //sets the specific barber node to nil in the database
        
        let ref = Database.database().reference()
        
        ref.child("Barbershops").child(barbershopId).child("Barbers").child(barberId).setValue(nil)
        
    }
    
}
