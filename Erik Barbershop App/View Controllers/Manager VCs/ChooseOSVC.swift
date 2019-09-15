//
//  ChooseOSVC.swift
//  Erik BarberShop Manager
//
//  Created by Brian on 3/18/19.
//  Copyright © 2019 Brian. All rights reserved.
//

import UIKit
import FirebaseAuth

///View controller where barbers choose which OS they are on.
class ChooseOSVC: UIViewController {
    
    @IBOutlet weak var iOSButton: UIButton!
    
    @IBOutlet weak var androidButton: UIButton!
    
    var barberData = [String:Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        //get the rounded corners for the buttons
        iOSButton.layer.cornerRadius = 10
        androidButton.layer.cornerRadius = 10
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //pass the barber name over to the EnterPhone view controller in case they are on android
        let enterPhoneVC = segue.destination as! EnterPhoneViewController
        
        enterPhoneVC.barberData = self.barberData
        
    }
    
    //if the user is on ios then there is no need for a phone number for right now
    @IBAction func iOSTapped(_ sender: Any) {
        
        barberData["operatingSystem"] = "iOS"
        self.performSegue(withIdentifier: Constants.managerStoryBoard.segues.goToPhoneVC, sender: self)
        
    }
    
    //go to the phone number screen if the user is on android
    @IBAction func androidTapped(_ sender: Any) {
        
        barberData["operatingSystem"] = "Android"
        self.performSegue(withIdentifier: Constants.managerStoryBoard.segues.goToPhoneVC, sender: self)
        
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
}
