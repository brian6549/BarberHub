//
//  ModalPopupViewController5.swift
//  Erik Barbershop App
//
//  Created by Brian on 6/4/19.
//  Copyright © 2019 Brian. All rights reserved.
//

import UIKit

///modal popup used to add/edit the barbershop's initial prices.
class ModalPopupViewController5: ModalPopupViewController2 {

    //MARK: - objects
    
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var priceTextField: UITextField!
    
    var prices = [[String:Int]]()
    
    var editingAt:Int?
    
    override func viewDidLoad() {
     
        // Do any additional setup after loading the view.
        titleLabel.adjustsFontSizeToFitWidth = true
        
        priceLabel.adjustsFontSizeToFitWidth = true
        
        nameTextField.returnKeyType = .done
        priceTextField.returnKeyType = .done
        
        //make this view controller the textfield delegate
        nameTextField.delegate = self
        priceTextField.delegate = self
        
        //get the rounded corners going
        dialogView.layer.cornerRadius = 10
        
        //dimView for the modal popup is disabled for this project because the view controller it is sitting on top of is handling it
        dimView.alpha = 0
        
        //enable return key
        nameTextField.enablesReturnKeyAutomatically = true
        priceTextField.enablesReturnKeyAutomatically = true
        
        //allow the keyboard to be dismissed when the user taps anywhere else on the screen
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))


    }
    
    override func okTapped(_ sender: Any) {
        
        guard ((nameTextField.text != nil && priceTextField.text != nil) && (nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" && priceTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "") && (nameTextField.text!.count < 50 && priceTextField.text!.count < 50)) else {
            //if textfield is empty or if character count is greater than 50 then don't continue
            showAlert("Error", "Invalid format.")
            return
        }
        
        //set the name and remove extraneous whitespaces
        let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        //update the prices
        var dict = [String:Int]()
        
        dict[name!] = Int(priceTextField.text ?? "0")
        
        if editingAt != nil  {
            
            prices[editingAt!] = dict
            editingAt = nil
            
        }
        
        if prices.contains(dict) {
            
            prices[prices.firstIndex(of: dict)!] = dict
        
        }
        
        else {
            
            prices.append(dict)
        
        }
        
        self.delegate?.setDimview()
        
        self.view.endEditing(true)
        
        nameTextField.text = ""
        priceTextField.text = ""
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    override func dismissTapped(_ sender: Any) {
        
        if editingAt != nil {
           
            editingAt = nil
            nameTextField.text = ""
            priceTextField.text = ""
            
        }
        
        self.delegate?.setDimview()
        
        self.view.endEditing(true)
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
}
