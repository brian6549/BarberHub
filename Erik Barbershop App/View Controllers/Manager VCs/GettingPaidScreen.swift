//
//  GettingPaidScreen.swift
//  Erik Barbershop App
//
//  Created by Brian on 7/8/19.
//  Copyright © 2019 Brian. All rights reserved.
//

import UIKit
import Firebase

///the final screen of the sign up process that takes the barber to square to finish setting up payment.
class GettingPaidScreen: UIViewController {

    @IBOutlet weak var label1: UILabel!
    
    @IBOutlet weak var label2: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
       
        //set up the labels
        label1.adjustsFontSizeToFitWidth = true
        
        label2.adjustsFontSizeToFitWidth = true
    }
    
    @IBAction func connectButtonTapped(_ sender: Any) {
    
        //open safari and go to square
        guard let url = URL(string: "https://connect.squareup.com/oauth2/authorize?client_id=sq0idp-LAdXivOb-LNAgOSHcvqAag&scope=MERCHANT_PROFILE_READ%20PAYMENTS_WRITE_ADDITIONAL_RECIPIENTS%20PAYMENTS_WRITE&session=false&locale=en-US&state=" + LocalStorageService.loadCurrentBarbershop()!.barbershopId!) else { return }
        
        UIApplication.shared.open(url)
        
        //go to the barber screen.
        BarberService.getBarberProfile(barbershopId: (LocalStorageService.loadCurrentBarbershop()?.barbershopId)!, barberId: Auth.auth().currentUser!.uid) { (b) in
            
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
                
                let storyboard = UIStoryboard(name: Constants.storyboards.mainStoryBoard, bundle: .main)
                
                let appointmentVC = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.barberTabBar)
                
                self.view.window?.rootViewController = appointmentVC
                self.view.window?.makeKeyAndVisible()
                
            }
            
        }
        
    }
    
}
