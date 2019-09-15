//
//  NotificationService.swift
//  Erik Barbershop App
//
//  Created by Brian on 2/25/19.
//  Copyright © 2019 Brian. All rights reserved.
//

import Foundation
import UserNotifications
import NotificationCenter


///Manages local notifications.
class NotificationService {
    
    /**
     Makes a local notification using notification objects on or before the date in the notification object.
     
     - Parameter notifications: An array of notification objects.
     
     - Precondition: The array or notification objects cannot be nil.
     
     
     */
    static func makeNotifications(notifications:[Notification]) {
        
        //if there are duplicate notifications then it won't really matter, the same reminder is going to be made anyway
        
        //variable that will allow for the creation of the content in the notification
        let content = UNMutableNotificationContent()
        
        // for each object in the array...
        for i in notifications {
            
            
            //set the body
            content.body = i.body!
            
            //set the sound to the default sound
            content.sound = UNNotificationSound.default
            
            //get the neccesary time components to schedule the notification
            var components = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute], from: i.date!)
            
            //if the notification will be delivered more than one hour before the scheduled date...
            if i.remindNMinutesBefore! >= 60 {
                
                //if the time that it will be delivered is right on the hour...
                if i.remindNMinutesBefore! % 60 == 0 {
                    
                    //just subtract the hours from the given date
                    components.hour = components.hour! - (i.remindNMinutesBefore!/60)
                    
                }
                    
                else {
                    
                    //if it's not right on the hour then two cases occur:
                    //Case 1: (example) if the time is 12:00 and the notification is to be sent 61 minutes before, then the hour will go back to 10 and not 11.
                    //Case 2: (example) if the time is 12:15 and the notification is to be sent 61 minutes before, then the hour will go back to 11.
                    
                    //MARK: - Case 1(goes back an extra hour)
                    
                    //grab the hour
                    let hour =  components.hour
                    
                    
                    if (components.minute! - i.remindNMinutesBefore!) <= (-60 * (i.remindNMinutesBefore!)/60) {
                        
                        //calculate how many hours will be subtracted from the time
                        let hourToSubtract:Int = (hour! - Int(ceil((Double(i.remindNMinutesBefore!)/60)))) //ceiling because case 1 goes back an extra hour
                        
                        components.hour = components.hour! - hourToSubtract
                        components.minute = (components.minute! - i.remindNMinutesBefore!) + (60 * hourToSubtract) //makes sure that the minutes component has a valid minute
                        
                        
                    }
                        //MARK: - Case 2(the hour does not go back an extra hour)
                        
                    else {
                        
                        let hour =  components.hour
                        
                        let hourToSubtract:Int = (hour! - i.remindNMinutesBefore!/60) //no need for a ceiling function because there is no need to go back an extra hour
                        
                        components.hour = components.hour! - i.remindNMinutesBefore!/60 //set the hour
                        components.minute = (components.minute! - i.remindNMinutesBefore!) + (60 * hourToSubtract) //set the minutes
                        
                    }
                    
                }
                
            }
                
            else {
                
                //if it's within the hour and more than 30 minutes into the hour, then only the minutes have to be adjusted
                if components.minute! >= 30 { //supposed to be checking the hour in the date picker date
                    
                    components.minute = components.minute! - i.remindNMinutesBefore!
                    
                    if components.minute! < 0 {
                        //just in case something weird happens such as it being 1:40 and the notification is to be delivered 50 minutes before(will change the hour too)
                        components.hour = abs(components.hour! - 1)
                        components.minute = components.minute! + 60
                        
                    }
                    
                }
                    
                    //if it's less than 30 minutes into the hour, then both the hour and minutes have to be adjusted
                else {
                    
                    components.hour = abs(components.hour! - 1)
                    components.minute = (components.minute! - i.remindNMinutesBefore!) + 60
                    
                }
                
            }
            
            //set the trigger
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            
            // Create the request object.
            let request = UNNotificationRequest(identifier: i.identifier! + "\(i.remindNMinutesBefore!)min", content: content, trigger: trigger)
            
            
            // Schedule the request.
            let center = UNUserNotificationCenter.current()
            center.add(request) { (error : Error?) in
                if let theError = error {
                    print(theError.localizedDescription)
                }
            }
        } //end of the for loop
        
    }
    
    /**
     Unschedules the notifications that are passed in.
     
     - Parameter notifications: Array of notifications that will be unscheduled.
     
     - Precondition: The array or notification objects cannot be nil.
     
     
     */
    static func removeNotifications(notifications:[Notification]) {
        
        //get the notification center for the app
        let center = UNUserNotificationCenter.current()
        
        //for each notification in the notifications array...
        for i in notifications {
            
            //unschedule the notification
            center.removePendingNotificationRequests(withIdentifiers: [i.identifier! + "\(i.remindNMinutesBefore!)min"])
            
        }
        
    }
    
    /**
     Makes a local notification using notification objects to be delivered on or after the date in the notification object.
     
     If there are multiple notification that have the same date, it is recommended to only pass one with the same date in order to avoid spamming the user.
     
     - Parameter notifications: An array of notification objects.
     
     - Parameter monthsToAdd: the number of months after the date in the notification object. This is the number of months later that the notification will be delivered.
     
     - Precondition: The array or notification objects cannot be nil.
     
     
     */
    static func makeFutureNotifications(notifications:[Notification], monthsToAdd: Int) {
        
        //if there are duplicate notifications then it won't really matter, the same reminder is going to be made anyway
        
        //variable that will allow for the creation of the content in the notification
        let content = UNMutableNotificationContent()
        
        // for each object in the array...
        for i in notifications {
            
            //set the body
            content.body = i.body!
            
            //set the sound to the default sound
            content.sound = UNNotificationSound.default
            
            //get the neccesary time components to schedule the notification
            var components = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute], from: i.date!)
            
            //set the date to X months from now
            components.month = components.month! + monthsToAdd
            
            //if the date goes into future years, then adjust the month and the year
            if components.month! > 12 {
                
                
                components.year = components.year! + ((components.month!)/12) //add years
                
                components.month = components.month!  % 12 //add months
                
                
            }
            
            //set the trigger
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            
            // Create the request object.
            let request = UNNotificationRequest(identifier: i.identifier! + "\(i.remindNMinutesBefore!)FUT", content: content, trigger: trigger)
            
            
            // Schedule the request.
            let center = UNUserNotificationCenter.current()
            center.add(request) { (error : Error?) in
                if let theError = error {
                    print(theError.localizedDescription)
                }
            }
        } //end of the for loop
        
        
    } //end of function
    
    /**
     Makes a local notification using notification objects to be delivered on or after the date in the notification object.
     
     If there are multiple notification that have the same date, it is recommended to only pass one with the same date in order to avoid spamming the user.
     
     - Parameter notifications: An array of notification objects.
     
     - Parameter daysToAdd: the number of days after the date in the notification object. This is the number of days later that the notification will be delivered.
     
     - Precondition: The array or notification objects cannot be nil.
     
     - Precondition: The number of days cannot be greater than or equal to 28. Use the overload with the 'monthsToAdd' if more days are needed.
     
     */
    static func makeFutureNotifications(notifications: [Notification], daysToAdd: Int) {
        
        if daysToAdd >= 28 {
            
            print("Please use the overload of this function that has 'monthsToAdd' as a parameter instead.")
            
            return
            
        }
        
        //if there are duplicate notifications then it won't really matter, the same reminder is going to be made anyway
        
        //variable that will allow for the creation of the content in the notification
        let content = UNMutableNotificationContent()
        
        for i in notifications {
            
            //set the body
            content.body = i.body!
            
            //set the sound to the default sound
            content.sound = UNNotificationSound.default
            
            //get the neccesary time components to schedule the notification
            var components = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute], from: i.date!)
            
            //thank you stack overflow, very cool!
            let range = Calendar.current.range(of: .day, in: .month, for: i.date!)
            let numDays = range?.count //the number of days in the month.
            
            components.day = components.day! + daysToAdd
            
            //going into next month
            if components.day! > numDays! {
                
                components.day = (components.day!) % numDays!
                components.month! += 1
                
                if components.month! > 12 {
                    
                    components.month! %= 12
                    components.year! += 1
                    
                }
                
            }
            
            //set the trigger
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            
            // Create the request object.
            let request = UNNotificationRequest(identifier: i.identifier! + "\(i.remindNMinutesBefore!)FUTDAYS", content: content, trigger: trigger)
            
            
            // Schedule the request.
            let center = UNUserNotificationCenter.current()
            center.add(request) { (error : Error?) in
                if let theError = error {
                    print(theError.localizedDescription)
                }
            }
            
        } //end of for loop
        
    }
    
    
    /**
     Unschedules the future notifications that are passed in.
     
     - Parameter notifications: Array of future notifications that will be unscheduled.
     
     - Precondition: The array or notification objects cannot be nil.
     
     
     */
    static func removeFutureNotifications(notifications: [Notification]) {
        
        //get the notification center for the app
        let center = UNUserNotificationCenter.current()
        
        //for each notification in the notifications array...
        for i in notifications {
            
            //unschedule the notification
            center.removePendingNotificationRequests(withIdentifiers: [i.identifier! + "\(i.remindNMinutesBefore!)FUT"])
            center.removePendingNotificationRequests(withIdentifiers: [i.identifier! + "\(i.remindNMinutesBefore!)FUTDAYS"])
            
        }
        
    }
    
    /**
     Unschedules all pending notifications for the signed in barber.
     
     - Parameter barberId: The Id of the signed in barber.
     
     */
    static func removeAllNotifications(barbershopId:String, barberId: String) {
        
        
        AppointmentService.getAppointments(barbershopId: barbershopId,barberId: barberId) { (appointments) in
            
            if appointments.count == 0 {
                
                return //nothing to delete
                
            }
            
            //delete all pending notifications
            for i in appointments {
                
                let thirtyMinuteNotification =  Notification(identifier: i.appointmentId!, remindOn: 30)
                let oneHourNotification =  Notification(identifier: i.appointmentId!, remindOn: 60)
                
                NotificationService.removeNotifications(notifications: [thirtyMinuteNotification,oneHourNotification])
                
            }
            
        }
        
    }
    
}
