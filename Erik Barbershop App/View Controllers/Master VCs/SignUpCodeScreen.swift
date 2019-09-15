//
//  SignUpCodeScreen.swift
//  Erik Barbershop App
//
//  Created by Brian on 6/10/19.
//  Copyright © 2019 Brian. All rights reserved.
//

import UIKit
import Firebase

///tells the manager how to get barbers to sign up
class SignUpCodeScreen: SplashScreen {

    @IBOutlet weak var codeLabel: UILabel!

    @IBOutlet weak var bottomLabel: UILabel!
    
    var barberData = [String:Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        codeLabel.text = Auth.auth().currentUser?.uid
        codeLabel.adjustsFontSizeToFitWidth = true
        
        bottomLabel.adjustsFontSizeToFitWidth = true
        
    }
    

    override func confirmButtonTapped(_ sender: Any) {
        
        //finish the process.
         BarbershopService.createBarbershop(data: &barberData, barbershopId: Auth.auth().currentUser!.uid)
        
        if LocalStorageService.loadCurrentMaster() == nil {
            
            let dict = barberData["manager"] as? [String:String]
            
            let establishment = dict!["establishmentType"]
            
            let manager = Manager(managerEmail: (Auth.auth().currentUser?.email)!, barbershopId: Auth.auth().currentUser!.uid, establishmentType: establishment!)
            
            LocalStorageService.saveCurrentManager(manager: manager)
            
            let managerStoryboard = UIStoryboard(name: Constants.storyboards.managerStoryBoard, bundle: nil)
            
            let managerVC = managerStoryboard.instantiateViewController(withIdentifier: Constants.managerStoryBoard.initialViewController)
            
            self.view.window?.rootViewController = managerVC
            self.view.window?.makeKeyAndVisible()
            
        }
            
        else {
            
            let masterStoryboard = UIStoryboard(name: Constants.storyboards.masterStoryBoard, bundle: nil)
            
            let masterVC = masterStoryboard.instantiateViewController(withIdentifier: Constants.masterStoryBoard.initialViewController)
            
            self.view.window?.rootViewController = masterVC
            self.view.window?.makeKeyAndVisible()
            
        }
        
    }
    
    
    @IBAction func backButtonTapped(_ sender: Any) {
    
        dismiss(animated: true, completion: nil)
    
    }
    
}
