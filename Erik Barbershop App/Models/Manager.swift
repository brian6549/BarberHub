//
//  Manager.swift
//  Erik Barbershop App
//
//  Created by Brian on 4/28/19.
//  Copyright © 2019 Brian. All rights reserved.
//

import Foundation
///The object that is used to represent a barbershop manager.
struct Manager {
    ///The manager's email.
    var managerEmail:String?
    ///The barbershopId of the barbershop that this manager manages
    var barbershopId:String?
    ///the type of establishment that the manager is managing.
    var establishmentType:String?
    
    ///trivial initializer
    init(managerEmail:String,barbershopId:String,establishmentType:String){
        
        self.managerEmail = managerEmail
        self.barbershopId = barbershopId
        self.establishmentType = establishmentType
        
        
    }
    
}
