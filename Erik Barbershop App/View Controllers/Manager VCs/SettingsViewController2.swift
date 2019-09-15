//
//  SettingsViewController2.swift
//  Erik Barbershop App
//
//  Created by Brian on 6/17/19.
//  Copyright © 2019 Brian. All rights reserved.
//

import UIKit
import Firebase

///settings view controller for the manager
class SettingsViewController2: SettingsViewController {

    @IBOutlet weak var codeLabel: UILabel!
   
    
    @IBOutlet weak var shareCodeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //set up the label to display the shareable sign up code
        
        codeLabel.text = "Sign-Up Code: \((Auth.auth().currentUser?.uid)!)"
        
       codeLabel.adjustsFontSizeToFitWidth = true
        
        shareCodeButton.layer.cornerRadius = 10
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
    }
    
    //MARK: - function to show the share sheet
    
    func showShareSheet(with content: String) {
        
        let activityViewController = UIActivityViewController(activityItems: [content as NSString], applicationActivities: nil)
        present(activityViewController, animated: true, completion: {})
        
    }
    
    @IBAction func shareCodeTapped(_ sender: Any) {
    
        showShareSheet(with: Auth.auth().currentUser!.uid)
        
    }
    //logging out
    override func logoutTapped(_ sender: Any) {
        
        do {
            
            try Auth.auth().signOut()
            
            LocalStorageService.clearCurrentManager()
            
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
 

}
