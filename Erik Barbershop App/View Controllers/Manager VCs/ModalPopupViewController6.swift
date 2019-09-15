//
//  ModalPopupViewController6.swift
//  Erik Barbershop App
//
//  Created by Brian on 7/2/19.
//  Copyright © 2019 Brian. All rights reserved.
//

import UIKit
///view controller where the address of the barbershop gets updated
class ModalPopupViewController6: ModalPopupViewController2 {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    

    override func okTapped(_ sender: Any) {
        
        //sends the new address to the database
        if (textField.text == nil || textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "") || textField.text!.count > 50 {
            //if textfield is empty or if character count is greater than 50 then don't continue
            showAlert("Error", "Invalid format.")
            return
        }
        
        //set the name and remove extraneous whitespaces
        let name = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        BarbershopService.setBarbershopAddress(for: (LocalStorageService.loadCurrentManager()?.barbershopId)!, address: name!)
        
        self.delegate?.setDimview()
        
        self.view.endEditing(true)
        
        self.dismiss(animated: true, completion: nil)
        
    }

}
