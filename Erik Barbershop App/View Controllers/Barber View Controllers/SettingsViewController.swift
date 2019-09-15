//
//  SettingsViewController.swift
//  Erik Barbershop App
//
//  Created by Brian on 1/27/19.
//  Copyright © 2019 Brian. All rights reserved.
//

import UIKit
import Firebase

///Settings view controller for the barber.
class SettingsViewController: UIViewController {
    
    
    @IBOutlet weak var logOutButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        logOutButton.layer.cornerRadius = 10
    
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        //make sure the barber profile still exists, if it does not then dismiss the view controller
        BarberService.observeBarberProfile(barbershopId: (LocalStorageService.loadCurrentBarber()?.barbershopId)!, barberId: (LocalStorageService.loadCurrentBarber()?.barberId)!) { (b) in
            
            if b == nil {
                
                
                do {
                    
                    //sign out using firebase auth methods
                    try Auth.auth().signOut()
                    
                    //remove all pending local notifications when the barber is signed out
                    NotificationService.removeAllNotifications(barbershopId: (LocalStorageService.loadCurrentBarber()?.barbershopId)!, barberId: (LocalStorageService.loadCurrentBarber()?.barberId)!)
                    
                    //clear local storage
                    LocalStorageService.clearCurrentBarber()
                    
                    
                    //change the window to show the login screen
                    let homeVC = self.storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.initialTabBar)
                    
                    self.view.window?.rootViewController = homeVC
                    self.view.window?.makeKeyAndVisible()
                    
                }
                    
                catch {
                    
                    self.viewWillAppear(true) //if there is an error signing out just try again
                    
                }
                
                
            }
            
        }
        
        
    }
    
    //exit settings
    @IBAction func doneTapped(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    
    @IBAction func logoutTapped(_ sender: Any) {
        
        //sign out using firebase auth methods
        
        do {
            
            let b = LocalStorageService.loadCurrentBarber()
            
            let barberId = b?.barberId
            
            BarberService.setToken(for: barberId!, in: (b?.barbershopId)!, token: "")
            
            //remove database observers for the barber's database location to minimize bad notifications
            let dbref = Database.database().reference().child("Barbershops").child((b?.barbershopId)!).child("Barbers").child(barberId!).child("appointments")
            
            dbref.removeAllObservers()
            
            //sign out using firebase auth methods
            try Auth.auth().signOut()
            
            //remove all pending local notifications when the barber is signed out
            NotificationService.removeAllNotifications(barbershopId: (LocalStorageService.loadCurrentBarber()?.barbershopId)!, barberId: (LocalStorageService.loadCurrentBarber()?.barberId)!)
            
            //clear local storage and go to the main view controller.
            
            LocalStorageService.clearCurrentBarber()
            
            
            let homeVC = self.storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.initialTabBar)
            
            self.view.window?.rootViewController = homeVC
            self.view.window?.makeKeyAndVisible()
            
        }
            
        catch {
            
            self.logoutTapped(self) //if there is an error signing out just try again
            
        }
        
    }
    
}
