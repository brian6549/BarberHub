//
//  CreateProfileViewController.swift
//  Erik BarberShop Manager
//
//  Created by Brian on 2/28/19.
//  Copyright © 2019 Brian. All rights reserved.
//

import UIKit
import FirebaseAuth

///view  controller that kicks off the process of creating a barbershop
class CreateProfileViewController: UIViewController,UITextFieldDelegate {
    
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var confirmButton: UIButton!
    
    @IBOutlet weak var theLabel: UILabel!
    
    ///The dictionary that will be shared accross view controllers and sent to the database
    var barberData = [String:Any]()
    ///The storyboard that this view controller is being summoned from
    var whichStoryBoard:String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        BarbershopService.getDefaultPhoto()
        
        confirmButton.layer.cornerRadius = 10
        
        theLabel.adjustsFontSizeToFitWidth = true
        
        textField.delegate = self
        
        textField.returnKeyType = .done
        
        textField.enablesReturnKeyAutomatically = true
        
        //allow the keyboard to be dismissed when the manager taps anywhere else on the screen
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        
    }
    
    
    //pass the barberName over in case a barber is on android
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let addressVC = segue.destination as! EnterAddressViewController
        
        addressVC.barberData = self.barberData
        
    }
    
    @IBAction func confirmTapped(_ sender: Any) {
        
        //check that there's a user logged in because we need the uid
        guard Auth.auth().currentUser != nil else {
            
            //no user logged in
            print("no user logged in")
            return
            
        }
        
        //check that the textfield has a valid name
        barberData["name"] = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        
        guard (barberData["name"] as? String != nil && barberData["name"] as? String != "") && ((barberData["name"] as? String)?.count)! <= 50 else {
            
            showAlert("Error", "Invalid format.")
            return
            
        }
        
        barberData["name"] = (barberData["name"] as! String).replacingOccurrences(of: "  ", with: "")
        
        self.view.endEditing(true)
        
        self.performSegue(withIdentifier: Constants.masterStoryBoard.segues.goToAddressVC, sender: self)
        
    }
    
    /**
     Function that is used to present alerts for an action that does not involve deleting a cell.
     
     - Parameter title: The title of the alert.
     - Parameter message: The message of the alert.
     
     */
    func showAlert(_ title: String, _ message:String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(alertAction)
        
        present(alert, animated: true)
        
    }
    
    //textField delegate method
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        confirmTapped(self)
        
        return true
        
    }
    
    
    @IBAction func backButtonTapped(_ sender: Any) {
        
        let masterStoryBoard = UIStoryboard(name: whichStoryBoard == nil ? Constants.storyboards.masterStoryBoard : Constants.storyboards.mainStoryBoard, bundle: nil)
        
        let masterVC = masterStoryBoard.instantiateViewController(withIdentifier: whichStoryBoard == nil ? Constants.masterStoryBoard.initialViewController : Constants.Storyboard.initialTabBar)
        
        self.view.window?.rootViewController = masterVC
        self.view.window?.makeKeyAndVisible()
        
    }
    
    
}
