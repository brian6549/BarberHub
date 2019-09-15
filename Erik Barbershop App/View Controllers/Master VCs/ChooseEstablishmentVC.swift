//
//  ChooseEstablishmentVC.swift
//  Erik Barbershop App
//
//  Created by Brian on 4/27/19.
//  Copyright © 2019 Brian. All rights reserved.
//

import Foundation
import Firebase
import UIKit

///view controller where the manager chooses the type of establishment that they are running
class ChooseEstablishmentVC:UIViewController {
    
    
    @IBOutlet weak var barbershopButton: UIButton!
    
    @IBOutlet weak var salonButton: UIButton!
    
    var barberData = [String:Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        barbershopButton.layer.cornerRadius = 10
        
        salonButton.layer.cornerRadius = 10
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let codeScreen =  segue.destination as! SignUpCodeScreen
        
        codeScreen.barberData = self.barberData
    }
    
    @IBAction func barbershopTapped(_ sender: Any) {
        
        barberData["establishmentType"] = "Barbershop"
        
        barberData["manager"] = ["managerEmail":Auth.auth().currentUser?.email!,"barbershopId":Auth.auth().currentUser?.uid,"establishmentType":"Barbershop"]
        
    }
    
    
    @IBAction func salonTapped(_ sender: Any) {
        
        barberData["establishmentType"] = "Salon"
        
        barberData["manager"] = ["managerEmail":Auth.auth().currentUser?.email!,"barbershopId":Auth.auth().currentUser?.uid,"establishmentType":"Salon"]
  
    }
    
    
    @IBAction func backButtonTapped(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
}
