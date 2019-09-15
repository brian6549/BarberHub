//
//  AppointmentService.swift
//  Erik Barbershop App
//
//  Created by Brian on 1/26/19.
//  Copyright © 2019 Brian. All rights reserved.
//

import Foundation
import Firebase

///Core component #2 of the app. Manages the appointments that have been made by users in the database.
class AppointmentService {
    
    //MARK: - for the barber's appointment table view
    
    
    /**
     Makes an appointment and sends it to the database
     
     - Parameter appointmentData: Data that will be sent to the database.
     
     - Precondition: None of the values in the dictionary can be nil.
     
     - Postcondition: appointmentData["appointmentId"] will be equal to the key of the node created in the database.
     
     
     */
    static func makeAppointment(appointmentData: inout [String:Any?]) { //'inout' makes it so that the parameter is not a 'let' constant
        
        
        //will put in thhe serivces thingy later
        var dbRef = DatabaseReference()
        
        dbRef = Database.database().reference().child("Barbershops").child(appointmentData["barbershopId"] as! String).child("Barbers").child(appointmentData["barberId"]!! as! String).child("appointments").childByAutoId()
        
        appointmentData["appointmentId"] = dbRef.key
        
        dbRef.setValue(appointmentData)  //end of closure
        
        
        //only save the appointment info to local storage  and return true if the write was successful
        LocalStorageService.saveAppointmentKey(dbRef.key!, appointmentData["barbershopId"]!! as! String, appointmentData["barberId"]!! as! String, appointmentData["time"] as! String)
        
    }
    
    
    /**
     Gets a specific barber's list of appointments.
     
     - Parameter barberId: The Id of the barber whose appointments will be retrieved.
     
     - Parameter barbershopId: The Id of the barber's associated barbershop.
     
     - Parameter completion: A closure containing the specific barber's list of appointments.
     
     
     */
    static func getAppointments(barbershopId: String,barberId: String,completion: @escaping (([Appointment]) -> Void)) {
        
        //getting a reference to the database
        let dbRef = Database.database().reference()
        
        //get the month and date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy, HH:mm"
        let date = dateFormatter.string(from: Date() - 1800)
        
        //make the database call
        
        //this call only grabs appointments that are from today and onward
        dbRef.child("Barbershops").child(barbershopId).child("Barbers").child(barberId).child("appointments").queryOrdered(byChild: "time").queryStarting(atValue: date).observe(.value, with: { (snapshot) in
            
            //the array that will be passed into the closure
            var retrievedAppointments = [Appointment]()
            
            //get the list of snapshots
            let snapshots = snapshot.children.allObjects as? [DataSnapshot]
            
            //checks if it's nil
            if let snapshots = snapshots {
                
                //loop through each snapshot and parse out the appointments
                
                for snap in snapshots {
                    
                    //try to create an appointment from a snapshot
                    let p = Appointment(snapshot: snap)
                    
                    //if successful, then add it to our array
                    if p != nil {
                        
                        retrievedAppointments.insert(p!, at: 0)
                        
                    }
                    
                }
                
            }
            
            //after parsing the snapshots, call the completion closure
            completion(retrievedAppointments)
            
        })
        
    }
    
    //MARK: - for the user's appointment table view
    
    /**
     
     Gets the user's list of appointments.
     
     - Parameter completion: A closure that contains the user's list of appoiontments.
     
     
     */
    static func getAppointments(completion: @escaping (([Appointment]) -> Void)) -> Void {
        
        //get a reference to the database
        let dbRef = Database.database().reference()
        
        //appintment array that will be passed into the closure
        var retrievedAppointments:[Appointment]? = [Appointment]()
        
        //load the user's stored appointment dictionary
        let appointmentDict = LocalStorageService.loadAppointmentKeys()
        
        //if it's nil then there is no need to continue beccause there is nothing
        guard  appointmentDict != nil else {
            
            return
            
        }
        
        //for if the dictionary exists but contains no appointments
        if appointmentDict?.count == 0 {
            
            
            completion(retrievedAppointments!)
            
        }
            
        else {
            
            //for each appointment in the dictionary, also grab the data from the databse
            for i in appointmentDict! {
                
                //make the database call
                
                dbRef.child("Barbershops").child(i.value[2]).child("Barbers").child(i.value[0]).child("appointments").child(i.key).queryOrdered(byChild: "time").observe(.value, with: { (snapshot) in
                    
                    //try to create an appointment from a snapshot
                    let p = Appointment(snapshot: snapshot)
                    
                    //if successful, then this is what will be returned
                    
                    //if any part of the appointment is nil, don't add it to the array and delete it from the stored dictionary(if this is the case, it's because it's not in the database)
                    
                    if p != nil && p?.appointmentId != nil {
                        
                        retrievedAppointments?.append(p!)
                        
                        completion(retrievedAppointments!)
                        
                    }
                        
                    else {
                        
                        //removes the appointment key from local storage and unschedules any notifications that are passed in
                        LocalStorageService.clearkey(i.key)
                        
                        let oneHourBefore = Notification(identifier:i.key, remindOn: 60)
                        let thirtyMinutesBefore = Notification(identifier: i.key, remindOn: 30)
                        
                        NotificationService.removeNotifications(notifications: [oneHourBefore,thirtyMinutesBefore])
                        
                        
                        //if there is nothing in the dictionary then go to the closure
                        if LocalStorageService.loadAppointmentKeys()?.count == 0 {
                            
                            completion(retrievedAppointments!)
                            
                        }
                        
                    }
                    
                }) //end of closure
                
            }
            
        } //end of else
        
    }
    
    
    /**
     
     Get any appointments that have been deleted from the database.
     
     - Parameter completion: A string array that contains the keys of appointments that have been deleted.
     
     */
    static func getDeletedAppointments(completion: @escaping ([String]) -> Void) -> Void {
        
        //get a reference to the database and call it
        let dbRef = Database.database().reference()
        
        dbRef.child("deletedAppointments").observe(.value, with: {(snapshot) in
            
            //array that will be passed into the closure
            var retrievedAppointmentKeys = [String]()
            
            let snapshots = snapshot.children.allObjects as? [DataSnapshot]
            
            //get Datasnapshots of the deletedAppointments to cast as a string and add to the array that will be returned to the closure
            if let snapshots = snapshots {
                
                for snap in snapshots {
                    
                    let keys = snap.value as? [String:String]
                    
                    //ensure that everything exists
                    if keys != nil {
                        
                        let appointmentKey = keys!["appointmentId"]
                        retrievedAppointmentKeys.append(appointmentKey!)
                        dbRef.child("deletedAppointments").child(snap.key).setValue(nil) //this doesn't need to be in the database anymore
                        
                    }
                    
                }
                
                
            }
            
            completion(retrievedAppointmentKeys)
            
        })
        
    }
    
    /**
     
     Deletes a specified appointment from the database.
     
     - Parameter appointmentKey: Appointment key for the appointment that will be deleted.
     
     - Parameter barbershopId: The Id of the barber's associated barbershop.
     
     - Parameter barberId: The barber that the appointment belongs to.
     
     - Parameter fromBarber: Checks whether it was the barber or the user that wantes to delete the appointment. Setting it to true means that the request is coming from the barber.
     
     */
    static func deleteAppointment(_ appointmentKey: String, _ barbershopId: String , _ barberId: String,_ fromBarber: Bool) {
        
        //get a reference to the database location
        var dbRef = Database.database().reference().child("Barbershops").child(barbershopId).child("Barbers").child(barberId).child("appointments").child(appointmentKey)
        
        //this is for the javascript file
        //makes sure that a notification is sent to the right person when an appointment is deleted
        
        if fromBarber == true {
            
            dbRef.child("fromBarber").setValue("Barber")
            
        } //end of if
            
        else {
            
            dbRef.child("fromBarber").setValue("User")  //end of closure
            
        } //end of else
        
        dbRef.setValue(nil)
        
        //for the user, clear the appointment from local storage once deleted
        if fromBarber == false {
            
            LocalStorageService.clearkey(appointmentKey)
            
        }
        
        //send information about what has been deleted to the database
        
        dbRef = Database.database().reference().child("deletedAppointments").childByAutoId()
        
        let deletedData = ["appointmentId":appointmentKey]
        
        
        dbRef.setValue(deletedData)
        
    } //end of function
    
    /**
     
     Deletes all the appointments for a specific barber.
     
     - Parameter barberId: The barberId of the barber whose appointments will be deleted.
     
     */
    static func deleteAllAppointments(for barberId: String) {
        
        //this one is tricky because it's hard to tell where this should happen
        
        //might leave as an emergency function because the user function already unschedules notifications when it doesn't find it in the database
        
        self.getAppointments { (appointments) in
            
            //for each appointment, delete it from the database
            for i in appointments {
                
                self.deleteAppointment(i.appointmentId!, i.barberId!, i.barbershopId!, true)
                
                //remove the scheduled notifications after removning from the database
                let oneHourBefore = Notification(identifier: i.appointmentId!, remindOn: 60)
                let thirtyMinutesBefore = Notification(identifier: i.appointmentId!, remindOn: 30)
                
                NotificationService.removeNotifications(notifications: [oneHourBefore,thirtyMinutesBefore])
                
            }
            
        } //end of closure
        
    }
    
}



