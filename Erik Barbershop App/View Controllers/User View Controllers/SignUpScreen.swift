//
//  SignUpScreen.swift
//  Erik Barbershop App
//
//  Created by Brian on 6/3/19.
//  Copyright © 2019 Brian. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI

class SignUpScreen: SplashScreen {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    override func confirmButtonTapped(_ sender: Any) {
        
        let authUI = FUIAuth.defaultAuthUI()
        
        //only registered barbers can sign in
        authUI?.allowNewEmailAccounts = true
        
        //create a firebase auth with pre built ui view controller and check that it isn't nil
        guard let authViewController = authUI?.authViewController() else { return }
        
        //set the login view controller as the delegate
        authUI?.delegate = self
        
        present(authViewController, animated: true, completion: nil)
        
        
    }

}

extension SignUpScreen: FUIAuthDelegate {
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        
        guard error == nil else {
            
            //error
           self.dismiss(animated: true, completion: nil)
            
           return
            
        }
        
        //get the manager/barbershop info
        let barbershop = authDataResult?.user
        
        if let barbershop = barbershop {
            
            BarbershopService.getBarbershop(barbershopId: barbershop.uid) { (barbershop) in
                
                if barbershop == nil {
                    
                    let masterStoryBoard = UIStoryboard(name: Constants.storyboards.masterStoryBoard, bundle: nil)
                    
                    //instantiate the profile creation view controller.
                    let createProfileVC = masterStoryBoard.instantiateViewController(withIdentifier: Constants.masterStoryBoard.createProfileVC) as! CreateProfileViewController
                    
                    createProfileVC.whichStoryBoard = "main"
                    
                    self.view.window?.rootViewController = createProfileVC
                    self.view.window?.makeKeyAndVisible()
                    
                }
                
                else {self.dismiss(animated: true, completion: nil)}
                
            }
            
        }
        
        else {self.dismiss(animated: true, completion: nil)}
        
    }
    
}
