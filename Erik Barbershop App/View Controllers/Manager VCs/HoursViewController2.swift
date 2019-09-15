//
//  HoursViewController2.swift
//  Erik Barbershop App
//
//  Created by Brian on 4/28/19.
//  Copyright © 2019 Brian. All rights reserved.
//

import UIKit

///The view controller where a manager can set the hours that the barbershop is open.
class HoursViewController2: HoursViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    override func confirmTapped(_ sender: Any) {
        
  
        //turn the times into strings.
        let timeFormat = DateFormatter()
        timeFormat.dateFormat = "h:mm a"
        
        let openingTime = timeFormat.string(from: datePicker1.date)
        let closingTime = timeFormat.string(from: datePicker2.date)
        
        barberData["hoursOpen"] = [openingTime,closingTime]
        
        BarbershopService.setBarbershopHours(for: (LocalStorageService.loadCurrentManager()?.barbershopId)!, hours: barberData["hoursOpen"] as! [String])
        
        dismiss(animated: true, completion: nil)
        
    }
    
}
