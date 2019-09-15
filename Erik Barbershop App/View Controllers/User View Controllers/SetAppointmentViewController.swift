//
//  SetAppointmentViewController.swift
//  Erik Barbershop App
//
//  Created by Brian on 1/22/19.
//  Copyright © 2019 Brian. All rights reserved.
//

import UIKit
import Firebase

//NOTE: - different barbers might be available at different times

///The view controller that lets the user choose the time of their appointment.
class SetAppointmentViewController: UIViewController {
    
    //MARK: - interface builder
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var dimView: UIView!
    
    @IBOutlet weak var setAppointmentButton: UIButton!
    
    
    ///the modal popup for the user to put their name in for the appointment
    var modalPopup: ModalPopupViewController?
    
    ///the appointment pbject that will be passed to the next view controller
    var appointment = Appointment()
    
    ///array of the appointments that have already been taken
    var appointmetTimes = [Appointment]()
    
    ///dictionary of the times that are being selected by other users for this specific barber
    var selectedTimes = [String:[String]]()
    
    ///an array that contains the days that the barber is available
    var availableDays = [Substring]()
    
    ///an array that contains the days that the barbershop is available
    var availableBarbershopDays = [Substring]()
    
    ///the barber object used to provide this view controller with information
    var barber = Barber()
    
    ///the barbershop object used to provide this view controller with information
    var barbershop = Barbershop()
    
    ///dictionary that contains the barbershop's current prices.
    var barbershopPrices = [[String:Int]]()
    
    var openCloseArray = [String]()
    
    var backward:Bool?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //sets rounded corners for the button
        setAppointmentButton.layer.cornerRadius = 10
        
        setAppointmentButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        //the dim view is off by default
        self.dimView.alpha = 0
        
        //get the modal popup ready
        modalPopup = storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.modalPopupViewController) as? ModalPopupViewController
        //resultVC?.delegate = self
        modalPopup?.modalPresentationStyle = .overCurrentContext
        
        modalPopup?.delegate = self
        
        //get the barbershop's current prices for the tableView
        barbershopPrices = barbershop.prices!
        
        //table view
        tableView.delegate = self
        tableView.dataSource = self
        
        //set the date picker
        datePicker.minimumDate = Date()
        
        //get the appointments that are already taken
        AppointmentService.getAppointments(barbershopId: barber.barbershopId!,barberId: barber.barberId!) { (appointments) in
            
            self.appointmetTimes = appointments
            
        }
        
        //grab the times that are currently being selected by other users
        TimeService.getTimes { (times) in
            
            
            self.selectedTimes = times
            
            
        }
        
        //grab the days that the barber is available
        BarberService.getDays(barberId: barber.barberId!, barbershopId: barber.barbershopId!) { (days) in
            
            self.availableDays = days
            
        }
        
        //grab the days that the barbershop is available
        BarbershopService.getBarbershopDays(barbershopId: barber.barbershopId!) { (days) in
            
            self.availableBarbershopDays = days
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //make sure the barber profile still exists, if it does not then dismiss the view controller
        BarberService.observeBarberProfile(barbershopId: barber.barbershopId!, barberId: barber.barberId!) { (b) in
            
            if b == nil {
                
                self.dismiss(animated: true, completion: nil)
                
            }
            
        } //end of closure
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //the user can only make an appointment up to 1 month in the future to avoid any weirdness
        let calendar = Calendar(identifier: .gregorian)
        
        var comps = DateComponents()
        
        comps.day = 31
        comps.minute = 20
        
        let maxDate = calendar.date(byAdding: comps, to: datePicker.date)
        
        datePicker.maximumDate = maxDate
        
    }
    
    
    /**
     Function that is used to present alerts.
     
     - Parameter title: The title of the alert.
     - Parameter message: The message of the alert.
     
     */
    func showAlert(_ title: String , _ message: String)
    {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(alertAction)
        
        present(alert, animated: true, completion: nil)
        
        
    }
    
    //when the button to summon the modal popup is tapped...
    @IBAction func setAppointmentTapped(_ sender: Any) {
        
        //there is a lot going on under this function
        
        //MARK: - WHAT NEEDS TO HAPPEN
        /*
         
         1. check if the date is not out of bounds
         2. check if the time is not out of bounds
         3. check if the barber or barbershop is available on the specific days
         4. check if the appointment has already been taken
         5. handle the situation when someone else is trying to book this appointment at the exact same time
         6. make sure that a customer cannot make an appointment an hour before
         7. make sure that a haircut type is chosen before opening the modal popup
         
         */
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy, HH:mm"
        
        //since the available days are just the names, a different date formatter is needed for checking
        let dateFormatterForAvailability = DateFormatter()
        dateFormatterForAvailability.dateFormat = "EEEE"
        
        
        //this is to check if the barbershop is open at the hour that the user chooses
        let timeFormat = DateFormatter()
        timeFormat.dateFormat = "h:mm a"
        let compareDate = timeFormat.string(from: datePicker!.date)
        
        if timeFormat.date(from: barbershop.hoursOpen![0])! > timeFormat.date(from: barbershop.hoursOpen![1])! {
            
            openCloseArray.append(barbershop.hoursOpen![1])
            openCloseArray.append(barbershop.hoursOpen![0])
            backward = true
            
        }
            
        else {
            
            openCloseArray.append(barbershop.hoursOpen![0])
            openCloseArray.append(barbershop.hoursOpen![1])
            
        }
        
        //this is the date that the users will actually see
        let dateFormatterForDisplay = DateFormatter()
        dateFormatterForDisplay.dateFormat = "EEEE, MMM d, yyyy, h:mm a"
        
        //date components used to compare the datePicker date and the current date.
        let componentsForAppointmentDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute], from: self.datePicker.date)
        
        let componentsForCurrentDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute], from: Date())
        
        //can't pick a date in the past
        if self.datePicker.date <= Date() {
            
            self.showAlert("Unavailable!", "Please choose another date.")
            return
            
        }
            
            //make sure that the users can't make an appointment 1 hour before the selected date
        else if (componentsForCurrentDate.day == componentsForAppointmentDate.day) && (componentsForCurrentDate.month == componentsForAppointmentDate.month) && (componentsForCurrentDate.year == componentsForAppointmentDate.year) && ((componentsForAppointmentDate.hour! - componentsForCurrentDate.hour!) <= 1) {
            
            showAlert("Error", "You cannot make this appointment.")
            
        }
            
        else if datePicker.date == datePicker.maximumDate {
            
            showAlert("Unavailable!", "You cannot pick this date yet.")
            return
            
        }
            
            //TODO: - figure out what is going on with the backward opening and closing times.
    
            //if the barber is not available today, don't make the appointment
        else if !availableDays.contains(Substring(dateFormatterForAvailability.string(from: datePicker.date))) || !availableBarbershopDays.contains(Substring(dateFormatterForAvailability.string(from: datePicker.date))) {
            
            self.showAlert("Unavailable!", "Please choose another date.")
            return
            
        }
            
        else {
           
            //check if the barbershop is actually open during the selected time.
            if backward != nil {
                
                if (timeFormat.date(from: compareDate)!  >= timeFormat.date(from: openCloseArray[0])!  &&  timeFormat.date(from: compareDate)! < timeFormat.date(from: openCloseArray[1])!) {
                    
                    self.showAlert("Unavailable!", "Please choose another date.")
                    return
                    
                    
                }
                
                
            }
                
            else {
              
                if !(timeFormat.date(from: compareDate)!  >= timeFormat.date(from: openCloseArray[0])!  &&  timeFormat.date(from: compareDate)! < timeFormat.date(from: openCloseArray[1])!) {
                    
                    self.showAlert("Unavailable!", "Please choose another date.")
                    return
                    
                }
    
            }
            //check if the appointment has already been taken
            for i in appointmetTimes {
                
                
                if dateFormatter.string(from: self.datePicker.date) == i.time {
                    
                    self.showAlert("Unavailable!", "Please choose another date.")
                    return
                    
                }
                
            }
            
            //check if the appointment is currently being selected by another user
            for i in selectedTimes {
                
                //checks if an appointment is being made with this specific barber at the time
                if i.value[0] == dateFormatter.string(from: datePicker!.date) && i.value[1] == barber.barberId && i.value[2] == barber.barbershopId {
                    
                    showAlert("Error", "Another user is already making this appointment.")
                    return
                    
                }
                
            }
            
            if tableView.indexPathForSelectedRow == nil {
                
                self.showAlert("Error", "Please choose a service.")
                return
                
            }
            
            //send the selectedTime to the database and save it to local storage
            let timeData:[String:String] = ["barberId": barber.barberId!, "time":dateFormatter.string(from: datePicker.date),"barbershopId":barber.barbershopId!]
            
            TimeService.selectedTime(timeData: timeData)
            
            
            //finish setting up the appointment and barber objects so that they can be passed to the next view controller
            
            let dateString = dateFormatter.string(from: self.datePicker.date)
            
            self.appointment.time = dateString
            
            self.appointment.timeToDisplay = dateFormatterForDisplay.string(from: datePicker.date)
            
            self.appointment.timeToDate = self.datePicker.date
            
            self.appointment.barberId = self.barber.barberId
            
            self.appointment.barberName = self.barber.barberName
            
            //make sure the barbers check the haircut type before the appointment begins to avoid being scammed(maybe have a past haircuts section in the future)
            
            /*
             logic for setting the amount that will be charged goes here
             
             */
            
            self.modalPopup?.appointment?.barberToken = self.barber.deviceToken
            
            self.modalPopup?.appointment = self.appointment
            
            self.modalPopup?.barber = self.barber
            
            self.modalPopup?.barbershop = self.barbershop
            
            //present the modal popup if it is not nil
            if self.modalPopup != nil {
                
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
                    self.dimView.alpha = 1
                }, completion: nil)
                
                
                DispatchQueue.main.async {
                    
                    self.present(self.modalPopup!, animated: true, completion: nil)
                    
                }
                
            }
            
        } //end of else
        
        
    } //end of function
    
    
    //dismiss button
    @IBAction func dismissTapped(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
}
//MARK: - prices table view methods

extension SetAppointmentViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Choose a service"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return barbershopPrices.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cells.priceCell) as! PricesTableViewCell
        
        //make the cell gray when it is selected
        let backgroundView = UIView()
        
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.50)
        
        cell.selectedBackgroundView = backgroundView
        
        cell.setPriceCell(with: barbershop.prices![indexPath.row])
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        for i in barbershop.prices![indexPath.row] {
            
            self.appointment.amount = Double(i.value * 100)
            self.appointment.haircutType = i.value != 0 ? i.key + "($\(i.value))": i.key
            
        }
        
    }
    
}


//MARK: - method for the dimView configuration

extension SetAppointmentViewController: SetdimViewProtocol {
    
    //turn the dimView off when the modal popup is dismissed
    func setDimview() {
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.dimView.alpha = 0
        }, completion: nil)
        
        self.viewWillAppear(true)
        
    }
    
    
}
