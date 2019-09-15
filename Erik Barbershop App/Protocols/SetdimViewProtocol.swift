//
//  SetAppointmentProtocol.swift
//  Erik Barbershop App
//
//  Created by Brian on 2/22/19.
//  Copyright © 2019 Brian. All rights reserved.
//

import Foundation


///Used for turning off the dim view in a view controller when a modal popup is dismissed.
protocol SetdimViewProtocol {
    
    ///Delegate function for turning off the dim view in a view controller.
    func setDimview()
    
}

