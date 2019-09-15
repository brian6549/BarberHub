//
//  SplashScreen.swift
//  Erik Barbershop App
//
//  Created by Brian on 5/2/19.
//  Copyright © 2019 Brian. All rights reserved.
//

import UIKit

///The splash screen that is shown to the user when a user first launches the app.
class SplashScreen: UIViewController {
    
    @IBOutlet weak var confirmButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        confirmButton.layer.cornerRadius = 10
        
    }
    
    
    @IBAction func confirmButtonTapped(_ sender: Any) {
        
        let storyBoard = UIStoryboard(name: Constants.storyboards.mainStoryBoard, bundle: .main)
        let homeScreen = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.initialTabBar)
        
        self.view.window?.rootViewController = homeScreen
        self.view.window?.makeKeyAndVisible()
        
    }
    
}
