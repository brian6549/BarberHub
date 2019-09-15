//
//  ViewAppointmentsController2.swift
//  Erik Barbershop App
//
//  Created by Brian on 2/18/19.
//  Copyright © 2019 Brian. All rights reserved.
//

import UIKit
import MessageUI


///View controller for the user to view their appointments. This is a subclass of the barber's ViewAppointmentsController.
class ViewAppointmentsController2: ViewAppointmentsController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
        
        //lets the delete appointment function know that the request is coming from a user.
        fromBarber = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        //should happen here too just in case any bad appointments are stored
        LocalStorageService.clearOutdatedAppointmentKeys()
        
        AppointmentService.getAppointments { (appointments) in
            
            //sort the table view by date in ascending order
            self.appointments = appointments.sorted(by: { $0.timeToDate!.compare($1.timeToDate!) == .orderedAscending })
            
            self.tableView.reloadData()
            
        }
        
        
        //has an appointment been canceled? reload the table view in case it is the user's appointment
        AppointmentService.getDeletedAppointments { (deletedAppointments) in
            
            
            //call appointment service again to get the table view back up to speed.
            AppointmentService.getAppointments { (appointments) in
                
                
                self.appointments = appointments.sorted(by: { $0.timeToDate!.compare($1.timeToDate!) == .orderedAscending })
                
                
                self.tableView.reloadData()
                
                if deletedAppointments.count > 0 {
                    
                    for i in 0...deletedAppointments.count - 1 {
                        
                        //remove any set notifications for appointments that have been cancelled
                        let oneHourBefore = Notification(identifier: deletedAppointments[i], remindOn: 60)
                        let thirtyMinutesBefore = Notification(identifier: deletedAppointments[i], remindOn: 30)
                        
                        NotificationService.removeNotifications(notifications: [oneHourBefore,thirtyMinutesBefore])
                        NotificationService.removeFutureNotifications(notifications: [oneHourBefore]) //remove the future notification too
                        
                    }
                    
                }
                
            }
            
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
    }
    
    //this function is slightly different for the user
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Get an appointment cell
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cells.appointmentCell, for: indexPath) as! AppointmentCell
        
        // Get the appointment for this row
        let appointment = appointments[indexPath.row]
        
        // Set the details for the cell
        cell.setAppointmentForUser(appointment!) //this line is what differentiates this function from the one in the superclass
        
        return cell
        
    }
    
    //slide to cancel action
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        
        let rowAction = UITableViewRowAction(style: .destructive, title: "Cancel") { (action, indexPath) in
            
            var componentsForAppointmentDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute], from: self.appointments[indexPath.row]!.timeToDate!)
            
            var componentsForCurrentDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute], from: Date())
            
            //appointment already passed(when the app is in the background and the appointment time passes, the table view does not refresh which causes some problems if not handled)
            guard Date() < self.appointments[indexPath.row]!.timeToDate! else{
                
                //nothing will happen if they hit cancel
                return
                
            }
            
            //cancellation two hours before the appointment.
            if (componentsForCurrentDate.day == componentsForAppointmentDate.day) && (componentsForCurrentDate.month == componentsForAppointmentDate.month) && (componentsForCurrentDate.year == componentsForAppointmentDate.year) && ((componentsForAppointmentDate.hour! - componentsForCurrentDate.hour!) <= 2) {
                
                self.showAlert("Error", "You cannot cancel this appointment.")
                
            }
                
                //cancellation on the same day of the appointment.
            else if (componentsForCurrentDate.day == componentsForAppointmentDate.day) && (componentsForCurrentDate.month == componentsForAppointmentDate.month) && ((componentsForCurrentDate.year == componentsForAppointmentDate.year)) {
                
                self.showAlert("Cancel Appointment", "Are you sure you want to cancel this appointment?(There will be a $5 cancellation fee)", indexPath.row, 5)
                
            }
                //cancellation 24 hours after the appointment has been made.
            else if let creationDate = self.appointments[indexPath.row]?.createdOn {
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/yyyy, HH:mm"
                
                let toDate = dateFormatter.date(from: creationDate)
                
                //logic for checking if it has been more than 24 hours since an appointment has been made.
                if (Date() > (toDate! + 86400)) {
                    
                    self.showAlert("Cancel Appointment", "Are you sure you want to cancel this appointment?(There will be a $2 cancellation fee)", indexPath.row, 2)
                    
                }
                
                else {
                    
                    self.showAlert("Cancel Appointment", "Are you sure you want to cancel this appointment?", indexPath.row,0)
                    
                }
           
            }
            
        }
        
        return [rowAction]
        
    }
    
    //action sheet
   override func showActionSheet(_ appointmentRow: Int) {
    
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel Appointment", style: .destructive, handler: { (action) in
            
            var componentsForAppointmentDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute], from: self.appointments[appointmentRow]!.timeToDate!)
            
            var componentsForCurrentDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute], from: Date())
            
            //appointment already passed(when the app is in the background and the appointment time passes, the table view does not refresh which causes some problems if not handled)
            guard Date() < self.appointments[appointmentRow]!.timeToDate! else {
                
                //nothing will happen if they hit cancel
                return
                
            }
            
            //cancellation two hours before the appointment.
            if (componentsForCurrentDate.day == componentsForAppointmentDate.day) && (componentsForCurrentDate.month == componentsForAppointmentDate.month) && (componentsForCurrentDate.year == componentsForAppointmentDate.year) && ((componentsForAppointmentDate.hour! - componentsForCurrentDate.hour!) <= 2) {
                
                self.showAlert("Error", "You cannot cancel this appointment.")
                
            }
            
            //cancellation on the same day of the appointment.
           else if (componentsForCurrentDate.day == componentsForAppointmentDate.day) && (componentsForCurrentDate.month == componentsForAppointmentDate.month) && ((componentsForCurrentDate.year == componentsForAppointmentDate.year)) {
                
                self.showAlert("Cancel Appointment", "Are you sure you want to cancel this appointment?(There will be a $5 cancellation fee)", appointmentRow, 2)
                
            }
            //cancellation 24 hours after the appointment has been made.
            else if let creationDate = self.appointments[appointmentRow]?.createdOn {
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/yyyy, HH:mm"
                
                let toDate = dateFormatter.date(from: creationDate)
                
                //logic for checking if it has been more than 24 hours since an appointment has been made.(the lazy way: 86400 is the amount of seconds that are in a day so just add that to the creation date to see if it has been 24 hours after)
                if (Date() > (toDate! + 86400)) {
                    
                    self.showAlert("Cancel Appointment", "Are you sure you want to cancel this appointment?(There will be a $2 cancellation fee)", appointmentRow, 2)
                    
                }
                //the appointment is being cancelled on time.
                else {
                    
                    self.showAlert("Cancel Appointment", "Are you sure you want to cancel this appointment?", appointmentRow,0)
                    
                }
                
            }
            
        })
    
    let contactAction = UIAlertAction(title: "Call", style: .default) { (action) in
        
        let url = URL(string: "tel://" + self.appointments[appointmentRow]!.contactNumber!)
        
        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        
    }
    
    let messageAction = UIAlertAction(title: "Message", style: .default) { (action) in
        
        let messageVC = MFMessageComposeViewController()
        
        messageVC.recipients = [(self.appointments[appointmentRow]?.contactNumber)!]
        messageVC.messageComposeDelegate = self
        
        self.present(messageVC, animated: true, completion: nil)
        
    }
    
    let getDirectionsAction = UIAlertAction(title: "Get Directions", style: .default) { (action) in
        
        let theRow = appointmentRow
        
        let theAddressSplit = self.appointments[theRow]?.barbershopAddress?.split(separator: ",")
        
        let theAdressJoined = (theAddressSplit?.joined(separator: ""))?.replacingOccurrences(of: " ", with: "+")
        
        //open google maps if available for direactions.
        if UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!) {
            
            UIApplication.shared.open(URL(string: "comgooglemaps://?&daddr=\(theAdressJoined!)&directionsmode=transit")!, options: [:], completionHandler: nil)
            
        }
         //open apple maps for directions if google maps is unavailable.
        else {
            
            UIApplication.shared.open(URL(string: "http://maps.apple.com/?daddr=\(theAdressJoined!)&dirflg=r")!, options: [:], completionHandler: nil)
            
        }
        
    }
    
        let dismissAction  = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        
        actionSheet.addAction(cancelAction)
    
        actionSheet.addAction(contactAction)
    
        actionSheet.addAction(messageAction)
    
        actionSheet.addAction(getDirectionsAction)
        
        actionSheet.addAction(dismissAction)
        
        present(actionSheet, animated: true)
        
    }
    
    
    /**
     Function that is used to present alerts.
     
     - Parameter title: The title of the alert.
     - Parameter message: The message of the alert.
     - Parameter appointmentRow: The row that the alert relates to.
     
     */
    func showAlert(_ title: String, _ message: String, _ appointmentRow: Int,_ cancellationFee: Int) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
            
            let myAppointment = self.appointments[appointmentRow]
            
            let barberId = self.appointments[appointmentRow]!.barberId
            
            let appointmentId = self.appointments[appointmentRow]!.appointmentId
            
            let barbershopId = self.appointments[appointmentRow]?.barbershopId
            
            BarberService.getBarberProfile(barbershopId: barbershopId!, barberId: barberId!, completion: { (barber) in
                
                self.barberObject = barber!
                
                UIView.animate(withDuration: 1, delay: 0, options: .curveEaseIn, animations: { self.dimView.alpha = 1 }, completion: nil)
                
                SquareChargeApi.processRefund(transactionId: (myAppointment?.transactionId)!, locationId: (myAppointment?.locationId)!, tenderId: (myAppointment?.tenderId)!, amount: Double(cancellationFee * 100) < (myAppointment?.amount)! ? (myAppointment?.amount)! - Double((cancellationFee * 100)): (myAppointment?.amount)! -
                    ((myAppointment?.amount)! - 100), key: UUID().uuidString, OAuthToken: self.barberObject.OAuthToken!, completion: { (success, failure) in
                    
                    if failure != nil {
                        
                        self.showAlert("Error", "An error occured while canceling this appointment, please try again.")
                        
                    }
                        
                    else {
                        
                        //delete the appointment and remove notifications
                        AppointmentService.deleteAppointment(appointmentId!,self.barberObject.barbershopId!, barberId!,self.fromBarber)
                        
                        let oneHourBefore = Notification(identifier: appointmentId!, remindOn: 60)
                        let thirtyMinutesBefore = Notification(identifier: appointmentId!, remindOn: 30)
                        
                        NotificationService.removeNotifications(notifications: [oneHourBefore,thirtyMinutesBefore])
                        NotificationService.removeFutureNotifications(notifications: [oneHourBefore]) //remove the future notification too
                        
                        self.appointments.remove(at: appointmentRow)
                        
                        AppointmentService.getAppointments(completion: { (appointments) in
                            
                            self.appointments = appointments.sorted(by: { $0.timeToDate!.compare($1.timeToDate!) == .orderedAscending })
                            self.tableView.reloadData()
                            
                        })
                        
                    }
                    
                    UIView.animate(withDuration: 1, delay: 0, options: .curveEaseOut, animations: { self.dimView.alpha = 0 }, completion: nil)
                })
                
            }) //end of getBarberProfile closure
            
        }) //end of UIAlertAction closure
        
        let cancelAction = UIAlertAction(title: "No", style: .default, handler: nil)
        
        alert.addAction(cancelAction)
        alert.addAction(alertAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    
}

extension ViewAppointmentsController2: MFMessageComposeViewControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        
        switch result {
            
        case .sent, .cancelled, .failed:
            dismiss(animated: true, completion: nil)
        default:
            break
        
        }
        
    }
    
}




