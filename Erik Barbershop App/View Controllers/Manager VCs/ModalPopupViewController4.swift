//
//  ModalPopupViewController4.swift
//  Erik Barbershop App
//
//  Created by Brian on 4/28/19.
//  Copyright © 2019 Brian. All rights reserved.
//

import UIKit

///The view controller where a manager can edit their barbershop's name.
class ModalPopupViewController4: ModalPopupViewController2 {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    override func okTapped(_ sender: Any) {
        
        if (textField.text == nil || textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "") || textField.text!.count > 50 {
            //if textfield is empty or if character count is greater than 50 then don't continue
            showAlert("Error", "Invalid format.")
            return
        }
        
        //set the name and remove extraneous whitespaces
        let name = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        
        BarbershopService.setBarbershopName(for: (LocalStorageService.loadCurrentManager()?.barbershopId)!, name: (name?.replacingOccurrences(of: "  ", with: "", options: .caseInsensitive, range: nil))!)
        
        self.delegate?.setDimview()
        
        self.view.endEditing(true)
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
}
