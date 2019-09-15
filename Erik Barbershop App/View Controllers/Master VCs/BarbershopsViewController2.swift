//
//  BarbershopsViewController2.swift
//  Erik Barbershop App
//
//  Created by Brian on 4/27/19.
//  Copyright © 2019 Brian. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI


///Master view controller.
class BarbershopsViewController2: BarbershopsViewController {
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        BarbershopService.getDefaultPhoto()
        
        
    }
    
    
    override func showActionSheet(selectedRow: Int) {
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let removeAction = UIAlertAction(title: "Remove Barbershop", style: .destructive) { (action) in
            
            self.showAlert("Remove Barbershop", "Are you sure you want to remove this barbershop?", barbershopRow: selectedRow)
            
        }
        
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        
        actionSheet.addAction(removeAction)
        actionSheet.addAction(dismissAction)
        
        present(actionSheet, animated: true,completion: nil)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let rowAction = UITableViewRowAction(style: .destructive, title: "Remove Barbershop") { (rowAction, indexPath) in
            
            self.showAlert("Remove Barbershop", "Are you sure you want to remove this barbershop?", barbershopRow: indexPath.row)
            
        }
        
        return [rowAction]
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        showActionSheet(selectedRow: indexPath.row)
        
    }
    
    @IBAction func addBarbershopTapped(_ sender: Any) {
        
        let authUI = FUIAuth.defaultAuthUI()
        
        //only registered barbers can sign in
        authUI?.allowNewEmailAccounts = true
        
        //create a firebase auth with pre built ui view controller and check that it isn't nil
        guard let authViewController = authUI?.authViewController() else { return }
        
        //set the login view controller as the delegate
        authUI?.delegate = self
        
        present(authViewController, animated: true, completion: nil)
        
    }
    
    
    @IBAction func exitTapped(_ sender: Any) {
        
        do {
            
            try Auth.auth().signOut()
            
            LocalStorageService.clearCurrentMaster()
            
            //instantiate main storyboard and go home.
            let storyboard = UIStoryboard(name: Constants.storyboards.mainStoryBoard, bundle: .main)
            
            let home = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.initialTabBar) as! UITabBarController
            
            self.view.window?.rootViewController = home
            self.view.window?.makeKeyAndVisible()
            
            
        }
            
        catch {
            
            print("could not sign out")
            
        }
        
    }
    
    
    func showAlert(_ title: String, _ message: String, barbershopRow: Int) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let removeAction = UIAlertAction(title: "Yes", style: .destructive) { (action) in
            
            BarbershopService.removeBarbershop(barbershopId: self.barbershops[barbershopRow].barbershopId!)
            
            self.barbershops.remove(at: barbershopRow)
            
            self.tableView.reloadData()
            
        }
        
        let alertAction = UIAlertAction(title: "No", style: .default, handler: nil)
        
        alert.addAction(alertAction)
        alert.addAction(removeAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    
}

extension BarbershopsViewController2 {
    
    override func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        
        guard error == nil else {
            
            //error
            return
            
        }
        
        //get the manager/barbershop info
        let barbershop = authDataResult?.user
        
        if let barbershop = barbershop {
            
            BarbershopService.getBarbershop(barbershopId: barbershop.uid) { (barbershop) in
                
                if barbershop == nil {
                    
                    //instantiate the profile creation view controller.
                    let createProfileVC = self.storyboard?.instantiateViewController(withIdentifier: Constants.masterStoryBoard.createProfileVC)
                    
                    self.view.window?.rootViewController = createProfileVC
                    self.view.window?.makeKeyAndVisible()
                    
                }
                
            }
            
        }
        
    }
    
}
