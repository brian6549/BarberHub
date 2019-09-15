//
//  ModalPopupViewController2.swift
//  Erik Barbershop App
//
//  Created by Brian on 1/29/19.
//  Copyright © 2019 Brian. All rights reserved.
//

import UIKit
import Firebase

///This class is made specifically for editing the barber's name. Also a subclass of ModalPopUpViewController.
class ModalPopupViewController2: ModalPopupViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        //make sure the right barberId and barbershopId are being used
        barber.barberId = LocalStorageService.loadCurrentBarber()?.barberId
        barber.barbershopId = LocalStorageService.loadCurrentBarber()?.barbershopId
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //DO NOT REMOVE THIS FUNCTION. THE SUPERCLASS DOES SOMETHING THAT MAKES THIS ONE CRASH.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //this function does not have anything because the view controller below this popup signs out automatically when the barber is deleted
        
    }
    
    /**
     Function that is used to present alerts.
     
     If the there is an error, then the barber will be kept in this view controller.
     
     - Parameter title: The title of the alert.
     - Parameter message: The message of the alert.
     - Parameter error: Indicates whether or not the alert was shown because there was an error.
     
     */
    func showAlert(_ title: String, _ message: String) {
        
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        var alertAction = UIAlertAction()
        
        //if there is no error then the view controller dismisses itself
        alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        
        alert.addAction(alertAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    //when the button to set the name is finally pressed
    override func okTapped(_ sender: Any) {
       
        if (textField.text == nil || textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "") || textField.text!.count > 50 {
            //if textfield is empty or if character count is greater than 50 then don't continue
            showAlert("Error", "Invalid format.")
            return
        }
        
        //set the name and remove extraneous whitespaces
        let name = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        
        BarberService.setName(for: barber.barberId!, in: barber.barbershopId!, name: (name?.replacingOccurrences(of: "  ", with: "", options: .caseInsensitive, range: nil))!)
        
        self.delegate?.setDimview()
        
        self.view.endEditing(true)
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    //dismiss button
    override func dismissTapped(_ sender: Any) {
        
        self.delegate?.setDimview()
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
}
