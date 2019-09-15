//
//  DetailViewController.swift
//  Erik Barbershop App
//
//  Created by Brian on 1/22/19.
//  Copyright © 2019 Brian. All rights reserved.
//

import UIKit
import SDWebImage


///The view controller that contains more details about a specific barber profile from the initial table view.
class DetailViewController: UIViewController {
    
    
    @IBOutlet weak var barberImage: UIImageView!
    
    
    @IBOutlet weak var barberName: UILabel!
    
    
    @IBOutlet weak var barberBio: UILabel!
    
    //the subclass button is also connected to this one. Whatever happens to this one happens to the other one.
    @IBOutlet weak var setAppointmentButton: UIButton!
    

    //barber and barbershop objects that will be passed to the next view controller
    var barber = Barber()
    var barbershop = Barbershop()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
       
        setAppointmentButton.layer.cornerRadius = 10
        
        setAppointmentButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        //if the barber is on Android change the title of the button.
        if barber.OAuthToken == nil || barber.operatingSystem == "Android" {
            
            setAppointmentButton.setTitle("Call", for: .normal)
            
        }
 
        barberBio.adjustsFontSizeToFitWidth = true
        
        barberName.text = barber.barberName
        barberBio.text = barber.bio
        
        //set the image
        if let urlString = barber.barberImage {
            
            let url = URL(string: urlString)
            
            guard url != nil else {
                //Couldn't create url object
                return
                
            }
            
            barberImage.sd_setImage(with: url) { (image, error, cacheType, url) in
                
                self.barberImage.image = image
                
            }
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //make sure the barber profile still exists, if it does not then show an error
        BarberService.observeBarberProfile(barbershopId: barber.barbershopId!,barberId: barber.barberId!) { (b) in
            
            if b == nil {
                
                self.showAlert("Error", "An error has occured.")
                
            }
            
        } //end of closure
        
    }
    
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let setAppointmentVC = segue.destination as! SetAppointmentViewController
        
        //pass the barber object to the next view controller
        setAppointmentVC.barber = barber
        setAppointmentVC.barbershop = barbershop
        
        
    }
    
    //this function will change depending on whether the barber is on ios or android
    @IBAction func appointmentTapped(_ sender: Any) {
        
        //if the barber is on Android, then call their number
        if setAppointmentButton.titleLabel?.text == "Call" {
            
            let url = URL(string: "tel://" + barber.phoneNumber!)
            
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            
            return
            
        }
        
        //go to the next view controller
        self.performSegue(withIdentifier: Constants.Segues.setAppointmentSegue, sender: self)
        
        
    }
    
    
    @IBAction func dismissTapped(_ sender: Any) {
        
        //go back home
        self.dismiss(animated: true, completion: nil)
        
        
    }
    
    /**
     Function that is used to present alerts.
     
     For this view controller: it dismisses it when there is an error.
     
     - Parameter title: The title of the alert.
     - Parameter message: The message of the alert.
     
     */
    func showAlert(_ title: String, _ message:String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
            
            self.dismiss(animated: true, completion: nil)
            
            
        })
        
        alert.addAction(alertAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
}
