//
//  LocalStorageService.swift
//  Erik Barbershop App
//
//  Created by Brian on 1/26/19.
//  Copyright © 2019 Brian. All rights reserved.
//


import Foundation

///Used for storing small but critical information in local storage.
class LocalStorageService {
    
    //MARK: - barber methods
    
    /**
     Saves a signed in barber to local storage.
     
     
     - Parameter barber: The barber object whose information will be saved in local storage.
     - Precondition: The barber object cannot be nil.
     
     
     */
    static func saveCurrentBarber(barber: Barber) {
        //get the standard user defaults
        let defaults = UserDefaults.standard
        
        //save the information
        defaults.set(barber.barberId, forKey: "storedBarberId")
        defaults.set(barber.barberName, forKey: "storedBarberName")
        defaults.set(barber.barbershopId, forKey: "storedBarbershopId")
        
        
    }
    
    /**
     Loads a signed in barber from local storage.
     
     
     - Returns: A barber object with a barberId and barberName filled out or nil if there is no barber in local storage.
     
     
     */
    static func loadCurrentBarber() -> Barber? {
        
        //get standard user defaults
        let defaults = UserDefaults.standard
        
        //load the information
        let username = defaults.value(forKey: "storedBarberName") as? String
        let userId = defaults.value(forKey: "storedBarberId") as? String
        let barbershopId = defaults.value(forKey: "storedBarbershopId") as? String
        
        //couldn't get a user, return nil
        guard username != nil && userId != nil && barbershopId != nil else {
            
            return nil
            
        }
        
        //return the user
        let b = Barber(barbershopId: barbershopId!,barberId: userId, barberName: username)
        return b
        
    }
    
    /**
     Deletes a signed in barber from local storage.
     
     */
    static func clearCurrentBarber() {
        
        //get standard user defaults
        let defaults = UserDefaults.standard
        
        //delete every piece of user data from local storage
        defaults.set(nil, forKey: "storedBarberId")
        defaults.set(nil, forKey: "storedBarberName")
        defaults.set(nil, forKey: "storedBarbershopId")
        
    }
    
    
    
    //MARK: - user methods
    
    
    /**
     Saves the key of a selectedTime node in the database.
     
     
     When the user is making an appointment, the time that they select is stored in the databse temporarily. If the user or app quits midway, this is a way to make sure that the unused node is deleted from the database later by also storing it in local storage.
     
     
     - Parameter timeKey: The key of the selectedTime node in the databse.
     
     
     */
    static func saveAppointmentTimeKey(timeKey: String) {
        
        //get standard user defaults
        let defaults = UserDefaults.standard
        
        //save the information
        defaults.set(timeKey, forKey: "storedTimeKey")
        
        
    }
    
    /**
     Loads a selectedTime key from local storage.
     
     
     - Returns: A selectedTime key or nil if there is not one saved in local storage.
     
     
     */
    static func loadAppointmentTimeKey() -> String? {
        
        //get standard user defaults
        let defaults = UserDefaults.standard
        
        //load the information
        let key = defaults.value(forKey: "storedTimeKey") as? String
        
        return key
        
        
    }
    
    /**
     Clears a selectedTime key in barber from local storage.
     
     */
    static func clearAppointmentTimeKey() {
        
        let defaults = UserDefaults.standard
        
        defaults.set(nil, forKey: "storedTimeKey")
        
    }
    
    
    
    /**
     Saves the key of an appointment that has been made to local storage.
     
     These keys are stored in local storage so that the user can access their appointments in the database later.
     
     
     
     - Parameter appointmentKey: The key of the appointment that will be saved.
     
     - Parameter barberId: The Id  of the barber that the appointment was made with.
     
     - Parameter barbershopId: The Id of the barbershop that the appointment was made in.
     
     - Parameter date: The date of the appointment.
     
     - Precondition: The date must be in "MM/dd/yyyy, HH:mm" format.
     
     */
    static func saveAppointmentKey(_ appointmentKey: String, _ barbershopId: String , _ barberId: String , _ date: String) {
        
        let defaults = UserDefaults.standard
        
        //if an array of saved appointment keys does not already exist, create a new one, else add the appointment key to the one that is already stored
        if defaults.value(forKey: "storedAppointments") == nil {
            
            
            var keyArray = [String:[String]]()
            
            keyArray[appointmentKey] = [barberId,date,barbershopId]
            
            defaults.set(keyArray, forKey: "storedAppointments")
            
        }
            
        else {
            
            
            var keyArray = defaults.value(forKey: "storedAppointments") as? [String:[String]]
            
            keyArray![appointmentKey] = [barberId,date,barbershopId]
            
            defaults.set(keyArray, forKey: "storedAppointments")
            
        }
        
    }
    
    /**
     Loads stored appointment keys from local storage.
     
     
     - Returns: A dictionary whose keys are appointmentIds and values are a string array containing the barberid at 0,date at 1, and barbershopId at 2.
     
     
     */
    static func loadAppointmentKeys() -> [String:[String]]? {
        
        let defaults = UserDefaults.standard
        
        let keys = defaults.value(forKey: "storedAppointments")
        
        return keys as? [String:[String]]
        
    }
    
    
    /**
     This is to clear keys for appointments that have already passed. This will be called during launch,when the application enters the background, and when the application is about to terminate.
     */
    static func clearOutdatedAppointmentKeys() {
        
        //get user defaults
        let defaults = UserDefaults.standard
        
        //if there is no stored dictionary then return because there is nothing to delete
        guard defaults.value(forKey: "storedAppointments") != nil else {
            
            return
            
        }
        
        //grab the date formatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy, HH:mm"
        //print(dateFormatter.date(from: "02/18/2019, 11:40"))
        
        //get the stored dictionary
        var keys = defaults.value(forKey: "storedAppointments") as? [String:[String]]
        
        //for every key in the dictionary...
        for i in keys! {
            
            //if the date has alredy passed on these appointments, remove it from the stored dictionary
            if dateFormatter.date(from: i.value[1])! < Date() - 1800 {
                
                keys?.removeValue(forKey: i.key)
                
            }
            
        }
        
        //save the updated dictionary
        defaults.set(keys, forKey: "storedAppointments")
        
    }
    
    /**
     Clears the specified appointment key.
     */
    static func clearkey(_ key: String) {
        
        //get user defaults
        let defaults = UserDefaults.standard
        
        //if there is no stored dictionary then return because there is nothing to delete
        guard defaults.value(forKey: "storedAppointments") != nil else {
            
            return
            
        }
        
        // load the dictionary
        var keys = defaults.value(forKey: "storedAppointments") as? [String:[String]]
        
        //loop through the dictionary until right key is found and then delete it
        for i in keys! {
            
            if i.key == key {
                
                keys?.removeValue(forKey: i.key)
                break
                
            }
            
        }
        
        //save the new dictionary
        defaults.set(keys, forKey: "storedAppointments")
        
    }
    
    
    /**
     For debugging purposes: clear the dictionary that contains the user's appointment keys.
     */
    static func clearAppointmentKeys() {
        
        //get the information
        let defaults = UserDefaults.standard
        
        //delete all of the keys
        defaults.set(nil, forKey: "storedAppointments")
        
    }
    
    
    
    
    //MARK: - device token methods
    
    
    /**
     Saves the device token to local storage.
     
     - Parameter token: The token that will be saved into local storage.
     
     */
    static func saveToken(_ token: String?) {
        
        //get the suer defaults
        let defaults = UserDefaults.standard
        
        //save the information
        defaults.set(token, forKey: "storedDeviceToken")
        
    }
    
    /**
     Loads stored token from local storage.
     
     
     - Returns: The saved device token or nil if there is not a saved device token.
     
     
     */
    static func loadToken() -> String? {
        
        //get user defaults
        let defaults = UserDefaults.standard
        
        //save the information
        let token = defaults.value(forKey: "storedDeviceToken") as? String
        
        return token
        
    }
    
    /**
     
     Clears stored token from local storage.
     
     */
    static func clearToken() {
        
        //get user defaults
        let defaults = UserDefaults.standard
        
        //delete the information
        defaults.set(nil, forKey: "storedDeviceToken")
        
        
    }
    
    //MARK: - Master methods
    
    static func saveCurrentMaster(email: String) {
        
        let defaults = UserDefaults.standard
        
        defaults.setValue(email, forKey: "masterSignIn")
        
    }
    
    static func loadCurrentMaster() -> String? {
        
        let defaults = UserDefaults.standard
        
        return defaults.value(forKey: "masterSignIn") as? String
        
    }
    
    static func clearCurrentMaster() {
        
        let defaults = UserDefaults.standard
        
        defaults.setValue(nil, forKey: "masterSignIn")
        
    }
    
    //these will also be used by the manager.
    static func saveDefaultPhoto(photo: [String:String]) {
        
        let defaults = UserDefaults.standard
        
        defaults.setValue(photo, forKey: "defaultPhotoUrl")
        
    }
    
    static func defaultPhoto() -> [String:String] {
        
        let defaults = UserDefaults.standard
        
        return defaults.value(forKey: "defaultPhotoUrl") as! [String:String]
        
    }
    
    //MARK: - manager methods
    
    /**
     saves the manager that is signed in into local storage
     
     - Parameter manager: The manager object whose information will be saved into local storage.
     
     
     */
    static func saveCurrentManager(manager: Manager) {
        
        let defaults = UserDefaults.standard
        
        defaults.setValue(manager.managerEmail, forKey: "storedManagerEmail")
        
        defaults.setValue(manager.barbershopId, forKey: "storedManagerBarbershopId")
        
        defaults.setValue(manager.establishmentType, forKey: "storedManagerEstablishmentType")
        
    }
    
    /**
     Loads the current manager from local storage.
     
     - Returns: an initialized manager object if there is a manager that was previously signed in on local storage or nil if not.
     
     */
    static func loadCurrentManager() -> Manager? {
        
        let defaults = UserDefaults.standard
        
        let email = defaults.value(forKey: "storedManagerEmail") as? String
        let barbershopId = defaults.value(forKey: "storedManagerBarbershopId") as? String
        let establishmentType = defaults.value(forKey: "storedManagerEstablishmentType") as? String
        
        guard email != nil && barbershopId != nil && establishmentType != nil else {
            
            return nil
            
        }
        
        return Manager(managerEmail: email!, barbershopId: barbershopId!, establishmentType: establishmentType!)
        
        
    }
    
    /**
     Clears the current manager that is signed in from local storage.
     
     */
    static func clearCurrentManager() {
        
        let defaults = UserDefaults.standard
        
        defaults.setValue(nil, forKey: "storedManagerEmail")
        defaults.setValue(nil, forKey: "storedManagerBarbershopId")
        defaults.setValue(nil, forKey: "storedManagerEstablishmentType")
        
    }
    
    /**
     Saves the signed in barbershop to local storage.
     
     - Parameter barbershop: the barbershop that will be saved to local storage
     
     
     */
    static func saveCurrentBarbershop(barbershop: Barbershop) {
        
        let defaults = UserDefaults.standard
        
        var dictionary = [String:String]()
        
        dictionary["barbershopId"] = barbershop.barbershopId
        
        dictionary["establishmentType"] = barbershop.establishmentType
        
        defaults.setValue(dictionary, forKey: "storedBarbershop")
        
        
    }
    
    /**
     loads the signed in barbershop from local storage.
     
     - Returns: the barbershop that was saved to local storage or nil if there is none.
     
     
     */
    static func loadCurrentBarbershop() -> Barbershop? {
        
        let defaults = UserDefaults.standard
        
        let dictionary = defaults.value(forKey: "storedBarbershop") as? [String:String]
        
        var storedBarbershop = Barbershop()
        
        storedBarbershop.barbershopId = dictionary?["barbershopId"]
        
        storedBarbershop.establishmentType = dictionary?["establishmentType"]
        
        guard storedBarbershop.establishmentType != nil && storedBarbershop.barbershopId != nil else {
            
            return nil
        }
        
        return storedBarbershop
        
    }
    
    ///clears the currently stored barbershop from local storage.
    static func clearCurrentBarbershop() {
        
        let defaults = UserDefaults.standard
        
        defaults.setValue(nil, forKey: "storedBarbershop")
        
    }
    
    
    //MARK: - miscellaneous
    
    /**
     Cheks if the app has been launched before.
     
     - Returns: true if the app has been launched before or false if it has not.
     
     */
    static func isFirstLaunch() -> Bool {
        
        let defaults = UserDefaults.standard
        
        if defaults.value(forKey: "launchedBefore") == nil {
            
            defaults.setValue("launched", forKey: "launchedBefore")
            return true
            
        }
            
        else {
            
            return false
            
        }
        
    }
    
}
