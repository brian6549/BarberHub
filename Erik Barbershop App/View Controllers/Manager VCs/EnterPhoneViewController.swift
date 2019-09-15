//
//  EnterPhoneViewController.swift
//  Erik BarberShop Manager
//
//  Created by Brian on 3/18/19.
//  Copyright © 2019 Brian. All rights reserved.
//

import UIKit
import FirebaseAuth

///View controller where barbers enter their phone number.
class EnterPhoneViewController: CreateProfileViewController {
    
    var operatingSystem: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //prevents crashing
        
    }
    
    override func confirmTapped(_ sender: Any) {
        
        //check that the textfield has a valid name
        let phoneNumber = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard phoneNumber != nil && phoneNumber != "" else {
            showAlert("Error", "Invalid format.")
            return
            
        }
        
        //makes sure that the phone number has no dashes in between
        barberData["phoneNumber"] = phoneNumber?.replacingOccurrences(of: "-", with: "")
        
        var barbershopId:String?
        
        if let manager = LocalStorageService.loadCurrentManager() {
            
            barbershopId = manager.barbershopId
            
        }
        
        else if let barbershop = LocalStorageService.loadCurrentBarbershop() {
            
            barbershopId = barbershop.barbershopId!
            
        }
        
        guard barbershopId != nil else {
            
            return
            
        }
        
        BarberService.createBarberProfile(in: barbershopId!, barberId: (Auth.auth().currentUser?.uid)!, barberName: barberData["barberName"] as! String, phoneNumber: barberData["phoneNumber"] as! String,operatingSystem: barberData["operatingSystem"] as! String) { (b) in
            
            if b ==  nil {
                //b has a failable initializer
                return
                
            }
                
            else {
                
                self.view.endEditing(true)
                
                //at the end it shows a brand new barber cell with the default image
                
                //might not want to do this yet.
                
                if LocalStorageService.loadCurrentManager() != nil {
                    
                    let homeVC = self.storyboard?.instantiateViewController(withIdentifier: Constants.managerStoryBoard.initialViewController) as! UITabBarController
                    
                    self.view.window?.rootViewController = homeVC
                    self.view.window?.makeKeyAndVisible()
                    
                    return
                    
                }
                
                else {
                    
                    //go to the next screen
                    
                    
                }
                
                
            }
            
        }
        
    }
    
    override func backButtonTapped(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    
    }
    
}
