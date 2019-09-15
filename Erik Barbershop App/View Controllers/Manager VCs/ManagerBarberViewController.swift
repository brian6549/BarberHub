//
//  ManagerBarberViewController.swift
//  Erik Barbershop App
//
//  Created by Brian on 4/28/19.
//  Copyright © 2019 Brian. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI

///The manager's main view controller.
class ManagerBarberViewController: ViewController {
    
    override func viewDidLoad() {
        //become the data source and delegate for the table view
        tableView.dataSource = self
        tableView.delegate = self
        
        //sets the navigation bar and button titles based on what kind of establishment the manager manages.
        navBar.topItem?.title = LocalStorageService.loadCurrentManager()?.establishmentType == "Barbershop" ? "Barbers": "Salon"
        
        loginButton.setTitle(LocalStorageService.loadCurrentManager()?.establishmentType == "Barbershop" ? "Add Barber": "Add Member", for: .normal)
        
        self.title = LocalStorageService.loadCurrentManager()?.establishmentType == "Barbershop" ? "Barbers": "Salon"
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //get the barbers in the manager's barbershop.
        BarberService.getBarbers(for: (LocalStorageService.loadCurrentManager()?.barbershopId)!) { (barbers) in
            
            self.barbers = barbers
            self.tableView.reloadData()
            
        }
        
    }
    
    /**
     Function that is used to present alerts.
     
     - Parameter title: The title of the alert.
     - Parameter message: The message of the alert.
     - Parameter barberRow: The row that the alert relates to.
     
     */
    func showAlert(_ title: String , _ message: String, _ barberRow: Int)
    {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
            
            let barberId = self.barbers[barberRow].barberId
            
            //this will make use of the javascript file for firebase
            BarberService.deleteBarber(in: (LocalStorageService.loadCurrentManager()?.barbershopId)!, with: barberId!)
            
            self.barbers.remove(at: barberRow)
            
            self.tableView.reloadData()
            
        })
        
        let cancelAction = UIAlertAction(title: "No", style: .default, handler: nil)
        
        alert.addAction(cancelAction)
        alert.addAction(alertAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    //action sheet
    func showActionSheet (_ appointmentRow: Int) {
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title:LocalStorageService.loadCurrentManager()?.establishmentType == "Barbershop" ? "Remove Barber": "Remove Member", style: .destructive, handler: { (action) in
            
            self.showAlert(LocalStorageService.loadCurrentManager()?.establishmentType == "Barbershop" ? "Remove Barber": "Remove Member", LocalStorageService.loadCurrentManager()?.establishmentType == "Barbershop" ? "Are you sure you want to remove this barber?": "Are you sure you want to remove this member?", appointmentRow)
            
        })
        
        let dismissAction  = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        
        actionSheet.addAction(cancelAction)
        
        actionSheet.addAction(dismissAction)
        
        present(actionSheet, animated: true)
        
    }
    
    //remove action for the table view
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let rowAction = UITableViewRowAction(style: .destructive, title: "Remove") { (action, indexPath) in
            
            self.showAlert(LocalStorageService.loadCurrentManager()?.establishmentType == "Barbershop" ? "Remove Barber": "Remove Member", LocalStorageService.loadCurrentManager()?.establishmentType == "Barbershop" ? "Are you sure you want to remove this barber?": "Are you sure you want to remove this member?", indexPath.row)
            
        }
        
        return [rowAction]
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        showActionSheet(indexPath.row)
        
    }
    
    override func loginTapped(_ sender: Any) {
        
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
    
    //go to settings screen
    override func dismissButtonTapped(_ sender: Any) {
       
        self.performSegue(withIdentifier: Constants.managerStoryBoard.segues.goToSettings, sender: self)
        
    }
    
}

extension ManagerBarberViewController: FUIAuthDelegate {
    
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
            BarberService.getBarberProfile(barbershopId: (LocalStorageService.loadCurrentManager()?.barbershopId)!, barberId: user.uid) { (u) in
                
                //if there is already a profile then there is no need to create one
                if u == nil {
                    
                    //send manager to profile creation screen
                    
                    //this will create a barberId, set the default availability, set the name(obviously), and a default photo
                    
                    let createProfileVC = self.storyboard?.instantiateViewController(withIdentifier: Constants.managerStoryBoard.createBarberProfileVC)
                    
                    self.view.window?.rootViewController = createProfileVC
                    self.view.window?.makeKeyAndVisible()
                    
                }
                
            }
            
        }
        
    }
    
}


