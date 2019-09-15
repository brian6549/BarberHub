//
//  HoursViewController.swift
//  Erik Barbershop App
//
//  Created by Brian on 4/27/19.
//  Copyright © 2019 Brian. All rights reserved.
//

import UIKit

///view controller that is used to set the barbershop's hours
class HoursViewController: UIViewController {
    
    //MARK: - date pickers and objects
    
    @IBOutlet weak var datePicker1: UIDatePicker!
    
    @IBOutlet weak var datePicker2: UIDatePicker!
    
    @IBOutlet weak var confirmButton: UIButton!
    
    var barberData = [String:Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set up date picker and button
        
        datePicker1.minuteInterval = 60
        
        confirmButton.layer.cornerRadius = 10
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    //move on to the next view controller
        
        let pricesVC = segue.destination as! PricesViewController
        
        pricesVC.barberData = self.barberData
        
    }
    
    
    @IBAction func confirmTapped(_ sender: Any) {
        
        //if the opening and closing hours are flipped when this happens, then this invalid configuration issue is no more. Just check if opening < closing and if that's the case then switch their places to get the hours when the barbershop is closed.(fixed)
        
        //get ready to turn the times into strings.
        let timeFormat = DateFormatter()
        timeFormat.dateFormat = "h:mm a"
        
        let openingTime = timeFormat.string(from: datePicker1.date)
        let closingTime = timeFormat.string(from: datePicker2.date)
        
        barberData["hoursOpen"] = [openingTime,closingTime]
        
        self.performSegue(withIdentifier: Constants.masterStoryBoard.segues.goToPricesVC, sender: self)
        
    }

     /**
     Function used to present alerts not relating to the table view
     
     - Parameter title: the title of the alert
     - Parameter message: the message that the alert will show
     
     */
 
    func showAlert(_ title: String, _ message:String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(alertAction)
        
        present(alert, animated: true)
        
    }
    
    
    @IBAction func backButtonTapped(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
}
