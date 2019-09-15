//
//  Notification.swift
//  Erik Barbershop App
//
//  Created by Brian on 3/4/19.
//  Copyright © 2019 Brian. All rights reserved.
//

import Foundation
import UserNotifications
import NotificationCenter

///notification model
struct Notification {
    
    ///The notification's identifier
    var identifier:String?
    ///The notification's body
    var body:String?
    ///The date that the notification will base its scheduling on
    var date:Date?
    ///The minutes before the given date that the notification will be delivered on
    var remindNMinutesBefore:Int?
    
    /**
     Main intializer.
     
     - Parameter identifier: The notification's identifier.
     
     - Parameter date: The date that the notification will base its scheduling on.
     
     - Parameter minutesBefore: The minutes before the given date that the notification will be delivered on.
     
     
     */
    init(identifier: String,body:String, date:Date, remindOn minutesBefore: Int) {
        
        
        self.identifier = identifier
        self.body = body
        self.date = date
        self.remindNMinutesBefore = abs(minutesBefore)
        
        
    }
    
    /**
     Initializes the notification's identifier and minutes before date. Everything else is initialized to nil.
     
     - Parameter identifier: The notification's identifier.
     
     - Parameter minutesBefore: The minutes before the given date that the notification will be delivered on.
     
     */
    init(identifier: String, remindOn minutesBefore: Int) {
        
        self.identifier = identifier
        self.remindNMinutesBefore = minutesBefore
        
    }
    
}
