//
//  ModalPopupViewController3.swift
//  Erik Barbershop App
//
//  Created by Brian on 1/29/19.
//  Copyright © 2019 Brian. All rights reserved.
//

import UIKit
import Firebase

///This class is made specifically for editing the barber's bio. Also a subclass of ModalPopUpViewController2.
class ModalPopupViewController3: ModalPopupViewController2,UITextViewDelegate {
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
       
        
        // Do any additional setup after loading the view.
        
        //make sure that the right barberId and barbershopId are being used
        barber.barberId = LocalStorageService.loadCurrentBarber()?.barberId
        barber.barbershopId = LocalStorageService.loadCurrentBarber()?.barbershopId
        
        dialogView.layer.cornerRadius = 10
        
        dimView.alpha = 0
        
        textView.layer.borderWidth = 1
        
        textView.enablesReturnKeyAutomatically = true //this is why this function is overridden: text view != text field
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        
        
    }
    
    override func okTapped(_ sender: Any) {
        
        //only allow 2 new line characters
        
        //this part makes sure that everything in the textfield is in the correct format before updating the database
        
        var newLineChars = [Character]() //this array will capture all the new line characters
        
        for char in textView.text {
            
            if char == "\n" {
                
                newLineChars.append(char)
                
            }
            
        }
        
        if textView.text == nil || textView.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || newLineChars.count > 2 || textView.text.count > 101 {
            //if textfield is empty, has more than two new line characters, or surpasses the character limit,then don't continue
            
            showAlert("Error", "Invalid format.")
            return
            
        }
        
        //set the bio and remove extraneous whitespaces
        let bio = textView.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        BarberService.setBio(for: barber.barberId!, in: barber.barbershopId!, bio: (bio?.replacingOccurrences(of: "  ", with: ""))!)
        
        self.delegate?.setDimview()
        
        self.view.endEditing(true)
        
        self.dismiss(animated: true, completion: nil)
        
        
    }
    
}
