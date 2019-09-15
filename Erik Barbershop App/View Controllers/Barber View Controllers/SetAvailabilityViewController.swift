//
//  SetAvailabilityViewController.swift
//  Erik Barbershop App
//
//  Created by Brian on 2/5/19.
//  Copyright © 2019 Brian. All rights reserved.
//

import UIKit
import Firebase

///The view controller where the barber sets their availability.
class SetAvailabilityViewController: UIViewController {
    
    //the array that the table view will use as its data source
    var days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    
    //days that are selected
    var daysAdded = ["","","","","","",""]
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var availabilityLabel: UILabel!
    
    //used to notify the table view that it doesn't need to peek into the database anymore
    var initialStagePassed = false
    
    let b = LocalStorageService.loadCurrentBarber()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        //make this view controller the delegate and data source for the table view.
        tableView.dataSource = self
        tableView.delegate = self
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //make sure the barber profile still exists, if it does not then dismiss the view controller
        BarberService.observeBarberProfile(barbershopId: (b?.barbershopId)!, barberId: (LocalStorageService.loadCurrentBarber()?.barberId)!) { (b) in
            
            if b == nil {
                
                //remove all pending local notifications when the barber is signed out
                NotificationService.removeAllNotifications(barbershopId: (self.b?.barbershopId)!, barberId: (self.b?.barberId)!)
                
                self.showAlert("Error", "An error has occured.",false,true)
                
            }
            
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //required data has been gathered from the server, initial stage has passed
        initialStagePassed = true
        
    }
    
    //cancel button
    @IBAction func cancelTapped(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    //done button
    @IBAction func doneTapped(_ sender: Any) {
        
        //if this array is empty, do not send it to the database
        var finalArray = daysAdded
        
        for i in finalArray {
            
            
            if i == "" {
                
                finalArray.remove(at: finalArray.firstIndex(of: i)!)
                
            }
            
        }
        
        //send the new info to the database if the array is not empty
        
        if !finalArray.isEmpty {
            
            let data = finalArray.joined(separator: ",")
            
            
            BarberService.setDays(days: data)
            showAlert("Success!","Your new days are: \(data)",false,false)
            
            
        }
            
        else {
            
            //no days have been chosen
            showAlert("Error","You must choose at least one day.",true,false)
            return
            
        }
        
    }
    
    /**
     Function that is used to present alerts.
     
     - If error is false then the alert action takes the user to the appointments view controllers, otherwise, it keeps them in this view controller.
     - If barberDeleted is true then it takes the barber back to the main view controller.
     
     - Parameter title: The title of the alert.
     - Parameter message: The message of the alert.
     - Parameter error: Indicates whether or not the alert was shown because there was an error.
     - Parameter barberDeleted: Indicates whether or not the alert was shown because a barber was deleted.
     
     */
    func showAlert(_ title: String , _ message: String, _ error: Bool, _ barberDeleted: Bool)
    {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if barberDeleted == true {
            
            
            let alertAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                
                do {
                    
                    //sign out using firebase auth methods
                    try Auth.auth().signOut()
                    
                    //clear local storage and go back to the main view controller
                    
                    LocalStorageService.clearCurrentBarber()
                    
                    let homeVC = self.storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.initialTabBar)
                    
                    self.view.window?.rootViewController = homeVC
                    self.view.window?.makeKeyAndVisible()
                    
                }
                    
                catch {
                    
                    //error signing out
                    self.showAlert("Error", "Could not sign out.", true, true)
                    
                }
                
            })
            
            alert.addAction(alertAction)
            
            present(alert, animated: true, completion: nil)
            
            
        }
            
        else {
            
            //only dismiss the view controller if there is not an error
            if error == false {
                
                let alertAction = UIAlertAction(title: "OK", style: .default, handler: { (alertaction) in
                    
                    self.dismiss(animated: true, completion: nil)
                    
                })
                
                alert.addAction(alertAction)
            }
                
            else {
                
                let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                
                alert.addAction(alertAction)
                
            }
            
            present(alert, animated: true, completion: nil)
            
        }
        
        
    }
    
    
}

//MARK: table view delegate methods

extension SetAvailabilityViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //just displaying all the days of the week
        return days.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //get a cell
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cells.dayCell, for: indexPath) as! DayTableViewCell
        
        //make the cell gray when it is selected
        let backgroundView = UIView()
        
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.50)
        
        cell.selectedBackgroundView = backgroundView
        
        cell.setCell(text: days[indexPath.row])
        
        //if the day is already in the databse, add it to the daysAdded array ---> only for the initial setup
        if initialStagePassed == false {
            
            let u = LocalStorageService.loadCurrentBarber()
            
            BarberService.getDays(barberId: (u?.barberId)!, barbershopId: (u?.barbershopId)!) { (day) in
                //will probably talk about the highlighting stuff in the documentation
                self.availabilityLabel.text = "Your Current Availability: " + day.joined(separator: ", ")
                
                //if the barber is already available on a specific day, then pre-select that cell
                if day.contains(Substring(self.days[indexPath.row])) && !cell.isSelected {
                    
                    tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                    self.daysAdded[indexPath.row] = self.days[indexPath.row]
                    
                }
                
            }
            
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if !daysAdded.contains(days[indexPath.row]) {
            
            //insert the day into the array if it's not already there
            daysAdded[indexPath.row] = days[indexPath.row]
            
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        //when the cell is deselected, remove it from the daysAdded array
        for i in 0...daysAdded.count - 1 {
            
            if days[indexPath.row] == daysAdded[i] {
                
                daysAdded[i] = ""
                break
                
            }
            
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        //header title for section
        return "When Are You Available?"
        
    }
    
}







