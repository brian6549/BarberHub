//
//  EnterAddressViewController.swift
//  Erik Barbershop App
//
//  Created by Brian on 4/27/19.
//  Copyright © 2019 Brian. All rights reserved.
//

import UIKit
import Firebase

///view controller that sets the initial address of the barbershop
class EnterAddressViewController: CreateProfileViewController {
    
    @IBOutlet weak var exmpleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        exmpleLabel.adjustsFontSizeToFitWidth = true
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let hoursVC = segue.destination as! HoursViewController
        
        hoursVC.barberData = self.barberData
        
        
    }
    
    override func confirmTapped(_ sender: Any) {
        
        barberData["address"] = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        
        guard (barberData["address"] as? String != nil && barberData["address"] as? String != "") && ((barberData["address"] as? String)?.count)! <= 50 else {
            
            showAlert("Error", "Invalid format.")
            return
            
        }
        
        //assumes that the address string is in the right format.
        self.performSegue(withIdentifier: Constants.masterStoryBoard.segues.goToHoursVC, sender: self)
        
    }
    
    override func backButtonTapped(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
}
