//
//  CreateBarberProfileVC.swift
//  Erik Barbershop App
//
//  Created by Brian on 4/28/19.
//  Copyright © 2019 Brian. All rights reserved.
//

import UIKit
import Firebase

///the view controller that kicks off the process of adding a new barber to the barbershop
class CreateBarberProfileVC: CreateProfileViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let phoneVC = segue.destination as! ChooseOSVC
        
        phoneVC.barberData = self.barberData
        
    }
    
    override func confirmTapped(_ sender: Any) {
        
        //check that there's a user logged in because we need the uid
        guard Auth.auth().currentUser != nil else {
            
            //no user logged in
            print("no user logged in")
            return
            
        }
        
        //check that the textfield has a valid name
        barberData["barberName"] = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        
        guard (barberData["barberName"] as? String != nil && barberData["barberName"] as? String != "") && ((barberData["barberName"] as? String)?.count)! <= 50 else {
            
            showAlert("Error", "Invalid format.")
            return
            
        }
        
        barberData["barberName"] = (barberData["barberName"] as! String).replacingOccurrences(of: "  ", with: "")
        
        
        self.performSegue(withIdentifier: Constants.managerStoryBoard.segues.goToOSVC, sender: self)
        
    }
    
    @IBAction override func backButtonTapped(_ sender: Any) {
        
        let managerVC = self.storyboard?.instantiateViewController(withIdentifier: Constants.managerStoryBoard.initialViewController) as! UITabBarController
        
        self.view.window?.rootViewController = managerVC
        self.view.window?.makeKeyAndVisible()
        
    }
    
}
