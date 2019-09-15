//
//  NewBarberViewController.swift
//  Erik Barbershop App
//
//  Created by Brian on 7/7/19.
//  Copyright © 2019 Brian. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI
///sign in and sign up screen
class NewBarberViewController: UIViewController {
    
    ///the object containing the barbershop's information.
    var barbershop = Barbershop()
    
    //MARK: - Buttons
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var dismissButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        loginButton.layer.cornerRadius = 10
        
        signUpButton.layer.cornerRadius = 10
        
        dismissButton.layer.cornerRadius = 10
    
    }
    
    @IBAction func loginTapped(_ sender: Any) {
    
        //create a firebase auth UI object
        let authUI = FUIAuth.defaultAuthUI()
        
        //only registered barbers can sign in
        authUI?.allowNewEmailAccounts = false
        
        //create a firebase auth with pre built ui view controller and check that it isn't nil
        guard let authViewController = authUI?.authViewController() else { return }
        
        
        //set the login view controller as the delegate
        authUI?.delegate = self
        
        present(authViewController, animated: true, completion: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let codeScreen = segue.destination as? SignUpCodeViewController
        
        codeScreen?.barbershop = self.barbershop
        
    }
    
    
    @IBAction func signUpTapped(_ sender: Any) {
   
        //peforms segue to the sign up code screen

    }
    
    
    @IBAction func dismissTapped(_ sender: Any) {
    
        dismiss(animated: true, completion: nil)
        
    }
    
}

extension NewBarberViewController: FUIAuthDelegate {
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        
        guard error == nil else {
            
            //error
            return
            
        }
        
        //get the barber
        let barber = authDataResult?.user
        
        //check if barber is nil
        if let barber = barber {
            
            //this means that there is a user, now check if they have a profile
            
            if barber.email == barbershop.manager!["managerEmail"] {
                
                //this is the manager for the barbershop, take them to the manager storyboard and save them to local storage.
                
                let manager = Manager(managerEmail: barber.email!, barbershopId: barbershop.barbershopId!, establishmentType: barbershop.establishmentType!)
                
                LocalStorageService.saveCurrentManager(manager: manager)
                
                let storyboard = UIStoryboard(name: Constants.storyboards.managerStoryBoard, bundle: nil)
                
                let managerVC = storyboard.instantiateViewController(withIdentifier: Constants.managerStoryBoard.initialViewController) as! UITabBarController
                
                self.view.window?.rootViewController = managerVC
                self.view.window?.makeKeyAndVisible()
                
            }
                
            else {
                //this is a barber that is in this barbershop, take them to the barber view controller, renew their OAuth token and save their device token.
                BarberService.getBarberProfile(barbershopId: self.barbershop.barbershopId!, barberId: barber.uid) { (b) in
                    
                    if b != nil {
                        
                        LocalStorageService.saveCurrentBarber(barber: b!)
                        
                        if b?.OAuthToken != nil {
                            
                            SquareChargeApi.renewOAuthToken(for: (b?.barberId)!,in: (b?.barbershopId)!, OAuthToken: (b?.OAuthToken)!)
                            
                        }
                        
                        if let token = LocalStorageService.loadToken() {
                            
                            BarberService.setToken(for: (b?.barberId)!, in: (b?.barbershopId)!, token: token)
                            
                        }
                            
                        else {
                            
                            BarberService.setToken(for: (b?.barberId)!, in: (b?.barbershopId)!, token: "")
                            
                        }
                        
                        let appointmentVC = self.storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.barberTabBar)
                        
                        self.view.window?.rootViewController = appointmentVC
                        self.view.window?.makeKeyAndVisible()
                        
                    }
                    
                }
                
            } //end of else
            
        } //end of if let
        
    } //end  of function
    
}
