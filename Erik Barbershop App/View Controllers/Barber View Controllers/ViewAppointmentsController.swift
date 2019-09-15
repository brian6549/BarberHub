//
//  ViewAppointmentsController.swift
//  Erik Barbershop App
//
//  Created by Brian on 1/27/19.
//  Copyright © 2019 Brian. All rights reserved.
//

import UIKit
import Firebase



///View controller for the barber to view their appointments.
class ViewAppointmentsController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var dimView: UIView!
    
    //array that will be used to store retrieved appointments and for the data source of the table view
    var appointments = [Appointment?]()
    
    //get the barber that is logged in
    let b = LocalStorageService.loadCurrentBarber()
    ///placeholder barber object that will house the OAuth Token to avoid having it leave the server environment.
    var barberObject = Barber(barbershopId: "someId",barberId:"myID", barberName: "name")
    
    //lets the delete appointment function know that the barber is the one making the request
    var fromBarber = true
    
    var showOAuthError:Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        //make this view controller the delegate and data source for the table view
        tableView.delegate = self
        tableView.dataSource = self
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //make sure the barber profile still exists, if it does not then dismiss the view controller
        BarberService.observeBarberProfile(barbershopId: (b?.barbershopId)!, barberId: (b?.barberId)!) { (b) in
            
            self.barberObject = b ?? Barber()
            
            if b?.OAuthToken == nil || b?.refreshToken == nil {
                
                self.showAlert("Warning!", "It looks like you have not connected a Square account. Please connect one in order to receive payments and appointments.")
                
            }
            
            if b == nil {
                
                //remove all pending local notifications when the barber is signed out
                NotificationService.removeAllNotifications(barbershopId: (self.b?.barbershopId)!, barberId: (self.b?.barberId)!)
                
                self.showAlert("Error", "An error has occured.",0,true)
                
            
            }
            
        }
        
        //get the barber's appointments from the database
        AppointmentService.getAppointments(barbershopId: (b?.barbershopId)! , barberId: (b?.barberId)!) { (appointments) in
            
            //remove notifications for deleted appointments
            AppointmentService.getDeletedAppointments(completion: { (deletedAppointments) in
                
                if deletedAppointments.count > 0 {
                    
                    for i in 0...deletedAppointments.count - 1 {
                        
                        let oneHourBefore = Notification(identifier: deletedAppointments[i], remindOn: 60)
                        let thirtyMinutesBefore = Notification(identifier: deletedAppointments[i], remindOn: 30)
                        
                        NotificationService.removeNotifications(notifications: [oneHourBefore,thirtyMinutesBefore])
                        
                    }
                    
                }
                
            })
            
    
            //make a notification for each new appointment as they come in
            for i in appointments {
                
                
                let oneHourNotification = Notification(identifier: i.appointmentId!, body: "Your appointment with \((i.name)!) is in 1 hour.", date: (i.timeToDate!), remindOn: 60)
                
                let  thirtyMinuteNotification = Notification(identifier: i.appointmentId!, body: "Your appointment with \((i.name)!) is in 30 minutes.", date: (i.timeToDate!), remindOn: 30)
                
                NotificationService.makeNotifications(notifications: [oneHourNotification,thirtyMinuteNotification])
                
                
            }
            
            //reload the data
            self.appointments = appointments.reversed()
            self.tableView.reloadData()
            
        }
        
    }
    
 
    //settings button
    @IBAction func settingsTapped(_ sender: Any) {
        
        self.performSegue(withIdentifier: "goToSettings", sender: self)
        
    }
    
    /**
     Function that is used to present alerts.
     
     - If error is true then that means a barber was deleted and has to be taken to the main view controller.
     
     - Parameter title: The title of the alert.
     - Parameter message: The message of the alert.
     - Parameter appointmentRow: The row that the alert relates to.
     - Parameter error: Indicates whether or not the alert was shown because there was an error.
     
     */
    func showAlert(_ title: String , _ message: String, _ appointmentRow: Int, _ error: Bool)
    {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if error == true {
            
            
            let alertAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                
                do {
                    
                    //sign out using firebase auth methods
                    try Auth.auth().signOut()
                    
                    //clear local storage
                    
                    LocalStorageService.clearCurrentBarber()
                    
                    //change the window to show the login screen
                    let homeVC = self.storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.initialTabBar)
                    
                    self.view.window?.rootViewController = homeVC
                    self.view.window?.makeKeyAndVisible()
                    
                }
                    
                catch {
                    
                    self.showAlert("Error", "Could not sign out.",0,true) //if there is an error signing out, try again
                    
                }
                
            })
            
            alert.addAction(alertAction)
            
            present(alert, animated: true, completion: nil)
            
            
        }
            
        else {
            
            let alertAction = UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
                
                let myAppointment = self.appointments[appointmentRow]
                
                let barberId = self.appointments[appointmentRow]!.barberId
                
                let appointmentId = self.appointments[appointmentRow]!.appointmentId
                
                let barbershopId = self.appointments[appointmentRow]!.barbershopId
                
                UIView.animate(withDuration: 1, delay: 0, options: .curveEaseIn, animations: { self.dimView.alpha = 1 }, completion: nil)
                
                SquareChargeApi.processRefund(transactionId: (myAppointment?.transactionId)!, locationId: (myAppointment?.locationId)!, tenderId: (myAppointment?.tenderId)! , amount: (myAppointment?.amount)!, key: UUID().uuidString , OAuthToken: self.barberObject.OAuthToken!, completion: { (success, failure) in
                    
                    if failure != nil {
                        
                        self.showAlert("Error", "An error occured while canceling this appointment, please try again.")
                        
                    }
                    
                    else {
                        
                        //remove the appointment only if a refund was successful
                        AppointmentService.deleteAppointment(appointmentId!, barbershopId!, barberId!,self.fromBarber)
                        
                        let oneHourBefore = Notification(identifier: appointmentId!, remindOn: 60)
                        let thirtyMinutesBefore = Notification(identifier: appointmentId!, remindOn: 30)
                        
                        NotificationService.removeNotifications(notifications: [oneHourBefore,thirtyMinutesBefore])
                        
                        self.appointments.remove(at: appointmentRow)
                        
                        self.tableView.reloadData()
                        
                    }
                    
                    UIView.animate(withDuration: 1, delay: 0, options: .curveEaseOut, animations: { self.dimView.alpha = 0 }, completion: nil)
                    
                })
        
            })
            
            let cancelAction = UIAlertAction(title: "No", style: .default, handler: nil)
            
            alert.addAction(cancelAction)
            alert.addAction(alertAction)
            
            present(alert, animated: true, completion: nil)
            
        }
        
    }
    
    /**
     Function that is used to present alerts for an action that does not involve deleting a cell.
     
     - Parameter title: The title of the alert.
     - Parameter message: The message of the alert.
     
     */
    func showAlert(_ title: String, _ message:String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "Later", style: .default, handler: nil)
        
        let connectAction = UIAlertAction(title: "Connect", style: .default) { (action) in
            
            //check oauth error
            
            if self.barberObject.OAuthToken == nil || self.b?.refreshToken == nil {
                
            //open safari and go to square
            guard let url = URL(string: "https://connect.squareup.com/oauth2/authorize?client_id=sq0idp-LAdXivOb-LNAgOSHcvqAag&scope=MERCHANT_PROFILE_READ%20PAYMENTS_WRITE_ADDITIONAL_RECIPIENTS%20PAYMENTS_WRITE&session=false&locale=en-US&state=" + LocalStorageService.loadCurrentBarber()!.barbershopId!) else { return }
            
            UIApplication.shared.open(url)
            
            }
            
        }
        
        alert.addAction(alertAction)
        alert.addAction(connectAction)
        
        present(alert, animated: true, completion: nil)
        
        
    }
    
    
    
    //action sheet
    func showActionSheet(_ appointmentRow: Int) {
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel Appointment", style: .destructive, handler: { (action) in
            
            //if the appointment date has already passed.
            guard Date() < self.appointments[appointmentRow]!.timeToDate! else {
                
                //nothing will happen if they hit cancel
                return
                
            }
                
    
            self.showAlert("Cancel Appointment", "Are you sure you want to cancel this appointment?", appointmentRow,false)
            
        })
        
        let dismissAction  = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        
        actionSheet.addAction(cancelAction)
        
        actionSheet.addAction(dismissAction)
        
        present(actionSheet, animated: true)
        
    }
    
}

//MARK: - table view methods

extension ViewAppointmentsController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return appointments.count //amount of cells = size of this array
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Get an appointment cell
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cells.appointmentCell, for: indexPath) as! AppointmentCell
        
        // Get the appointment for this row
        let appointment = appointments[indexPath.row]
        
        // Set the details for the cell
        cell.setAppointment(appointment!)
        
        return cell
        
    }
    
    //slide to cancel action
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let rowAction = UITableViewRowAction(style: .destructive, title: "Cancel") { (action, indexPath) in
            
            //if the appointment date has already passed.
            guard Date() < self.appointments[indexPath.row]!.timeToDate! else {
                
                //nothing will happen if they hit cancel
                return
                
            }
            
            self.showAlert("Cancel Appointment", "Are you sure you want to cancel this appointment?", indexPath.row,false)
                
            
        }
        
        return [rowAction]
        
    }
    
    //when the barber taps a row, show the action sheet
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        showActionSheet(indexPath.row)
        
    }
    
}


