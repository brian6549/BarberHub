//
//  SignUpCodeViewController.swift
//  Erik Barbershop App
//
//  Created by Brian on 7/7/19.
//  Copyright © 2019 Brian. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI

///screen where a barber inputs the sign up code
class SignUpCodeViewController: CreateBarberProfileVC {

    ///barbershop objects that the view controllers after this one will use for information.
    var barbershop = Barbershop()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        
    }
    
    ///checks if the sign up code is valid
    override func confirmTapped(_ sender: Any) {
        
        let code = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard (code != nil && code != "") && (code?.count)! <= 50 else {
            
            showAlert("Error", "Invalid format.")
            return
            
        }
        
        guard code == barbershop.barbershopId else {
            
            showAlert("Error", "Invalid code")
            return
        }
        
        LocalStorageService.saveCurrentBarbershop(barbershop: barbershop)
        
       //go to the firebase email screen
        
        //create a firebase auth UI object
        let authUI = FUIAuth.defaultAuthUI()
        
        //only registered barbers can sign in
        authUI?.allowNewEmailAccounts = true
        
        //create a firebase auth with pre built ui view controller and check that it isn't nil
        guard let authViewController = authUI?.authViewController() else { return }
        
        
        //set the login view controller as the delegate
        authUI?.delegate = self
        
        present(authViewController, animated: true, completion: nil)
        
    }
    
    override func backButtonTapped(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    
    }
    
}

extension SignUpCodeViewController: FUIAuthDelegate {
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        
        guard error == nil else {
            print("an error has happened")
            return
            
        }
        
        //get the user
        let user = authDataResult?.user
        
        //check if user is nil
        if let user = user {
            
            //if they don't have a profile, then take the manager to a detail screen
            BarberService.getBarberProfile(barbershopId: barbershop.barbershopId!, barberId: user.uid) { (u) in
                
                //if there is already a profile then there is no need to create one
                if u == nil {
                    
                    //send manager to profile creation screen
                    
                    //this will create a barberId, set the default availability, set the name(obviously), and a default photo
                    
                    let storyboard = UIStoryboard(name: Constants.storyboards.managerStoryBoard, bundle: nil)
                    
                    let createProfileVC = storyboard.instantiateViewController(withIdentifier: Constants.managerStoryBoard.createBarberProfileVC)
                    
                    self.view.window?.rootViewController = createProfileVC
                    self.view.window?.makeKeyAndVisible()
                    
                } //end of nested if
                
            } //end of closure
            
        } //end of if
        
    } //end of function
    
}
