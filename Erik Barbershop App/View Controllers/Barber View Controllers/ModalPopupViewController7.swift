//
//  ModalPopupViewController7.swift
//  Erik Barbershop App
//
//  Created by Brian on 7/9/19.
//  Copyright © 2019 Brian. All rights reserved.
//

import UIKit

///modal popup for updating the barber's phone number.
class ModalPopupViewController7: ModalPopupViewController6 {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func okTapped(_ sender: Any) {
        
        //sends the new phone number to the database
        if (textField.text == nil || textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "") || textField.text!.count > 50 {
            //if textfield is empty or if character count is greater than 50 then don't continue
            showAlert("Error", "Invalid format.")
            return
        }
        
        //set the name and remove extraneous whitespaces
        let name = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        BarberService.setBarberPhoneNumber(for: (LocalStorageService.loadCurrentBarber()?.barberId)!, in: (LocalStorageService.loadCurrentBarber()?.barbershopId)!, phoneNumber: name!)
        
        self.delegate?.setDimview()
        
        self.view.endEditing(true)
        
        self.dismiss(animated: true, completion: nil)
        
    }

}
