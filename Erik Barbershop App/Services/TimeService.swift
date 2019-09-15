//
//  TimeService.swift
//  Erik Barbershop App
//
//  Created by Brian on 2/13/19.
//  Copyright © 2019 Brian. All rights reserved.
//

import Foundation
import Firebase

///Manages the times that are being selected from other users in the database.
class TimeService {
    
    /**
     Puts the appointment time that is being selected by a user in the database so that no other user can choose it while the appointment is being made.
     
     This function also saves the key to local storage if successful.
     
     - Parameter timeData: The data that will be put in the database.
     
     - Precondition: The value of the "time" key in the timeData dictionary must be in "MM/dd/yyyy, HH:mm" format.
     
     */
    static func selectedTime(timeData: [String:String]) {
        
        let dbRef = Database.database().reference().child("selectedTimes").childByAutoId()
        
        dbRef.setValue(timeData)
        
        LocalStorageService.saveAppointmentTimeKey(timeKey: dbRef.key!) //save the key to local storage
        
        
    } //end of function
    
    
    /**
     Gets appointment times that are currently being selected by other users for a specific barber.
     
     - Parameter completion: A closure with the array of times that are currently being selected by other users for specific barbers.
     
     
     */
    static func getTimes(completion: @escaping (([String:[String]]) -> Void)) -> Void {
        
        //get a reference to the database
        let dbRef = Database.database().reference()
        
        //make the database call
        //this call only grabs the times that are from today and onward
        dbRef.child("selectedTimes").observe(.value, with: { (snapshot) in
            
            
            //dictionary that will be passed to the closure
            var retrievedTimes = [String:[String]]()
            
            //get the list of snapshots
            let snapshots = snapshot.children.allObjects as? [DataSnapshot]
            
            if let snapshots = snapshots {
                
                for snap in snapshots {
                    
                    //for each snapshot get the key and value then add it to the dictionary that will be passed to the closure.
                    let timeData = snap.value as? [String: String]
                    
                    let timeKey = snap.key
                    
                    let time = timeData!["time"]
                    
                    let barberId = timeData!["barberId"]
                    
                    let barbershopId = timeData!["barbershopId"]
                    
                    let array = [time,barberId,barbershopId]
                    
                    retrievedTimes[timeKey] = array as? [String] //the appointment time will be the first element,the barberId will be the second element, and the barbershopId will be the third element
                    
                }
                
            }
            
            //after parsing the snapshots, call the completion closure
            completion(retrievedTimes)
            
        })
        
    }
    
    /**
     Clears the specified time key from selectedTimes in the database.
     
     - Parameter timeId: The key that will be deleted from the database.
     
     */
    static func clearSelectedTimeKey(timeId: String) {
        
        //get a reference to the database
        var dbRef = DatabaseReference()
        
        //make a database call
        dbRef = Database.database().reference().child("selectedTimes").child(timeId)
        
        //remove the time key from both the database and local storage.
        dbRef.setValue(nil) //this one does not need a completion block because it always tries the operation again at some other time
        
        LocalStorageService.clearAppointmentTimeKey()
        
    }
    
}
