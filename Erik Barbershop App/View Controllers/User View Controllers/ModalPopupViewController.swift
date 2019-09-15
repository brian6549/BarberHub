//
//  ModalPopupViewController.swift
//  Erik Barbershop App
//
//  Created by Brian on 1/23/19.
//  Copyright © 2019 Brian. All rights reserved.
//

import UIKit
import CoreTelephony
import SquareInAppPaymentsSDK
import PassKit


///The view controller where the user enters their name for the appointment.
class ModalPopupViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: - interface builder.
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var paymentTitleLabel: UILabel!
    
    @IBOutlet weak var amountTippedLabel: UILabel!
    
    @IBOutlet weak var dialogView: UIView!
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var dimView: UIView!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    
    ///the appointment object whose information will be sent to the database
    var appointment:Appointment?
    
    ///the barber object whose information will be sent to the database
    var barber = Barber()
   
    ///the barbershop object whose information will be sent to the database
    var barbershop = Barbershop()
    
    ///the dictionary that will be used to make an appointment
    var appointmentData = [String:Any?]()
    
    ///boolean for checking if something went wrong using apple pay
    var applePayError:Bool?
    
    ///boolean for checking if a payment has been authorized using apple pay.
    var authorizingApplePay:Bool?
    
    ///used to call the dim view delegate when the modal popup is dismissed
    var delegate: SetdimViewProtocol?
    
    ///the amount that a user has chosen to tip the barber.
    var amountTipped:Double?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        titleLabel.adjustsFontSizeToFitWidth = true
        
        textField.returnKeyType = .go
        
        //make this view controller the textfield delegate
        textField.delegate = self
        
        //get the rounded corners going
        dialogView.layer.cornerRadius = 10
        
        //dimView for the modal popup is disabled for this project because the view controller it is sitting on top of is handling it
        dimView.alpha = 0
        
        //enable return key
        textField.enablesReturnKeyAutomatically = true
        
        //allow the keyboard to be dismissed when the user taps anywhere else on the screen
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //make sure the barber profile still exists, if it does not then dismiss the view controller
        
        paymentTitleLabel.adjustsFontSizeToFitWidth = true
        
        BarberService.observeBarberProfile(barbershopId: barber.barbershopId!,barberId: barber.barberId!) { (b) in
            
            if b == nil {
                
                self.dismissTapped(self)
                
            }
            
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //get the appointments that are currently being selected by other users
        TimeService.getTimes { (times) in
            
            var repeated = [String]()
            
            for i in times {
                
                guard LocalStorageService.loadAppointmentTimeKey() != nil else {
                    
                    return
                    
                }
                
                if times[LocalStorageService.loadAppointmentTimeKey()!] == i.value {
                    
                    repeated.append(i.key)
                    
                }
                
            }
            
            
            if repeated.count >= 2 {
                
                
                for i in repeated {
                    
                    TimeService.clearSelectedTimeKey(timeId: i)
                    
                }
                
                
                self.dismiss(animated: true, completion: nil)
                self.delegate?.setDimview()
                self.showAlert("Error", "Another user is already making this appointment.",true)
            }
            
        }
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //go back to the user appointments view controller
        let appointmentVC = segue.destination as! UITabBarController
        
        appointmentVC.selectedIndex = 1
        
    }
    
    
    @IBAction func okTapped(_ sender: Any) {
        
        if textField.text == nil || textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || (textField.text?.count)! > 50 {
            
            //if textfield is empty, then don't continue
            showAlert("Error", "Invalid format.",true)
            return
            
        }
        
        //check if the user is offline or not on LTE. If either of these things are true then do not continue.
        let networkInfo = CTTelephonyNetworkInfo()
        let networkString = networkInfo.serviceCurrentRadioAccessTechnology
        
        if Reach.connectionStatus().description == "Offline" || !(networkString!["0000000100000001"] == CTRadioAccessTechnologyLTE) && Reach.connectionStatus().description == "Online (WWAN)"  {
            
            showAlert("Error", "You are offline.", true)
            return
            
        }
        
        //remove any extraneous whitespaces
        appointment?.name = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        appointment!.name =  appointment!.name?.replacingOccurrences(of: "  ", with: "", options: .caseInsensitive, range: nil) //removes double spaces too
        
        
        var userToken = LocalStorageService.loadToken()
        
        if userToken == nil {
            
            userToken = ""
            
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy, HH:mm"
        
        dateFormatter.date(from: (appointment?.time)!)
        
        guard Date() < dateFormatter.date(from: (appointment?.time)!)! else {
            dismissTapped(self)
            return
        }
        
        if self.authorizingApplePay == true {
            
            self.showAlert("Error", "Appointment is already being made", false)
            return
            
        }
        
        SQIPInAppPaymentsSDK.squareApplicationID = "sq0idp-LAdXivOb-LNAgOSHcvqAag"
        
        
        //set the appointment
        appointmentData = ["name":appointment?.name,"time":appointment?.time,"userToken":userToken,"barberToken":barber.deviceToken,"barberId": appointment?.barberId,"appointmentId":"", "barberName": appointment?.barberName, "fromBarber":"","timeToDisplay": appointment?.timeToDisplay,"transactionId":"incoming","amount":appointment?.amount,"locationId":"incoming","haircutType":appointment?.haircutType,"tenderId":"incoming","createdOn":"incoming","contactNumber":barber.phoneNumber,"barbershopAddress":barbershop.address,"barbershopId":barbershop.barbershopId,"barbershopName": barbershop.name!]
        
       
        if segmentedControl.selectedSegmentIndex == 0 {
            
            requestApplePayAuthorization()
            
        }
            
        else if segmentedControl.selectedSegmentIndex == 1 {
            
            showCardEntryForm()
            
        }
        
    }
    
    
    //dismiss button
    @IBAction func dismissTapped(_ sender: Any) {
        
        if self.authorizingApplePay == true {
            return
        }
        
        TimeService.clearSelectedTimeKey(timeId: LocalStorageService.loadAppointmentTimeKey()!)
        
        self.delegate?.setDimview()
        
        self.view.endEditing(true)
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    /**
     Function that is used to present alerts.
     
     If error is false then the alert action takes the user to the appointments view controllers, otherwise, it keeps them in this view controller.
     
     - Parameter title: The title of the alert.
     - Parameter message: The message of the alert.
     - Parameter error: Indicates whether or not the alert was shown because there was an error.
     
     */
    func showAlert(_ title: String , _ message: String, _ error: Bool)
    {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        var alertAction = UIAlertAction()
        
        if error == true {
            
            alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            
        }
            
        else {
            
            alertAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                
                self.performSegue(withIdentifier: Constants.Segues.goToTabBarSegue, sender: self)
                
            })
            
        }
        
        alert.addAction(alertAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    //textField delegate method
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.view.endEditing(true)
        
        okTapped(self)
        
        return true
        
    }
    
    //stepper function for changing the amount that the user wants to tip
    @IBAction func stepperChange(_ sender: UIStepper) {
        
        amountTipped = Double(sender.value) //value of the stepper
        amountTippedLabel.text = "$" + Int(sender.value).description //updates label
        
    }
    
}

//MARK: - ApplePay

extension ModalPopupViewController {
    
    func requestApplePayAuthorization() {
        guard SQIPInAppPaymentsSDK.canUseApplePay else {
            return;
        }
        
        let paymentRequest = PKPaymentRequest.squarePaymentRequest(
            // Set to your Apple merchant ID
            merchantIdentifier:"merchant.com.barberhub.brian",
            countryCode: "US",
            currencyCode: "USD")
        
        let amount = ((appointmentData["amount"] as! Double) + (Double(amountTipped ?? 0) * 100)) / 100
        
        let amount2 = ceil((Double(amount) * (0.029)) + 1.30)
        
        // Payment summary information will be displayed on the Apple Pay sheet.
        paymentRequest.paymentSummaryItems = [
          PKPaymentSummaryItem(label: (appointment?.barberName)!, amount: NSDecimalNumber(value: amount)), PKPaymentSummaryItem(label: "BarberHub Fee", amount: NSDecimalNumber(value:  ceil((Double(amount) * (0.029)) + 1.30))),
          PKPaymentSummaryItem(label: "Total", amount:  NSDecimalNumber(value: Double(amount) + amount2)) //gets calculated before
        ]
        
        let paymentAuthorizationViewController =
            PKPaymentAuthorizationViewController(paymentRequest: paymentRequest)
        
        paymentAuthorizationViewController!.delegate = self
        
        present(paymentAuthorizationViewController!, animated: true, completion: nil)
        
    }
    
}

extension ModalPopupViewController: PKPaymentAuthorizationViewControllerDelegate {
    
    func paymentAuthorizationViewController(
        _ controller: PKPaymentAuthorizationViewController,
        didAuthorizePayment payment: PKPayment,
        handler completion: @escaping (
        PKPaymentAuthorizationResult) -> Void){
        
        self.authorizingApplePay = true
        
        let nonceRequest = SQIPApplePayNonceRequest(payment: payment)
        
        nonceRequest.perform { (cardDetails, error) in
       //if they(Barber) don't want to work with debit or credit cards that's fine, just send the whole fee to my personal account.
        
            if let cardDetails = cardDetails {
                
                //calculates the total amount that will actually be charged.
                let amount = ((self.appointmentData["amount"] as! Double) + ((self.amountTipped ?? 0) * 100))
                
                let amount2 = ceil((Double(amount) * (0.029)) + 130)
                
                let total = Double(amount) + amount2
                
                self.appointmentData["amount"] = ceil(total/100) * 100
                
                SquareChargeApi.processPayment(nonce: cardDetails.nonce
                    , amount: self.appointmentData["amount"] as! Double, key: UUID().uuidString, OAuthToken: self.barber.OAuthToken!, isSubscribed: self.barbershop.isSubscribed!, completion: {(transactionResult, transactionErrors,networkError) in
                        
                        //networking error
                        if networkError != nil {
                            
                            completion(PKPaymentAuthorizationResult(status: .failure, errors: [networkError!]))
                            
                        }
                            //transactionError
                        else if transactionErrors != nil {
                            
                            let error:Error = paymentError.UhOh
                            
                            completion(PKPaymentAuthorizationResult(status: .failure, errors: [error]))
                        }
                            //successful transaction
                        else {
                            
                            //mark the time that this appointment was created on.
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "MM/dd/yyyy, HH:mm"
                            
                            self.appointmentData["transactionId"] = transactionResult!["transactionId"]
                            self.appointmentData["locationId"] = transactionResult!["locationId"]
                            self.appointmentData["tenderId"] = transactionResult!["tenderId"]
                            
                            
                            self.appointmentData["createdOn"] = dateFormatter.string(from: Date())
                            
                            //set the appointment
                            AppointmentService.makeAppointment(appointmentData: &self.appointmentData)
                            
                            //clear the selectedTime key from local storage and the database
                            TimeService.clearSelectedTimeKey(timeId: LocalStorageService.loadAppointmentTimeKey()!)
                            
                            //make a local notifications and end the function
                            let oneHourNotification = Notification(identifier: self.appointmentData["appointmentId"]!! as! String, body: "Your appointment with \((self.appointment?.barberName)!) is in 1 Hour.", date: (self.appointment?.timeToDate)!, remindOn: 60)
                            
                            let  thirtyMinuteNotification = Notification(identifier: self.appointmentData["appointmentId"]!! as! String, body: "Your appointment with \((self.appointment?.barberName)!) is in 30 Minutes.", date: (self.appointment?.timeToDate)!, remindOn: 30)
                            
                            let futureNotification = Notification(identifier: self.appointmentData["appointmentId"]!! as! String, body: "Want to look even more beautiful? Make an appointment at a barbershop or salon near you, they will not let you down :)", date: (self.appointment?.timeToDate)!, remindOn: 60)
                            
                            NotificationService.makeNotifications(notifications: [oneHourNotification,thirtyMinuteNotification])
                            
                            //future notification
                            NotificationService.makeFutureNotifications(notifications: [futureNotification], daysToAdd: 15)
                            
                            self.applePayError = false
                            
                            //appointment and transaction made successfully.
                            completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
                            
                        }
                }) //end of charge function
                
            } //end of if let
                
            else if let error = error {
                print(error)
                self.applePayError = true
                completion(PKPaymentAuthorizationResult(status: .failure, errors: [error]))
            }
            
        } //end of nonceRequest.perform
        
    } //end of didAuthorizePayment
    
    func paymentAuthorizationViewControllerDidFinish(
        _ controller: PKPaymentAuthorizationViewController) {
        
        dismiss(animated: true, completion: {
            
            if self.applePayError == true || self.applePayError == nil {
                
                return
                
            }
                
            else {
                
                self.authorizingApplePay = false
                
                self.view.endEditing(true)
                
                self.showAlert("Success!", "Your appointment has been set!",false)
                
            }
            
        })
        
    }
    
}

//MARK: - CardEntry view controller delegate methods.

extension ModalPopupViewController: SQIPCardEntryViewControllerDelegate {
    func showCardEntryForm() {
        let theme = SQIPTheme()
        
        // Customize the card payment form
        theme.tintColor = .black
        theme.saveButtonTitle = "Submit"
        
        let cardEntryForm = SQIPCardEntryViewController(theme: theme)
        cardEntryForm.delegate = self
        
        // The card entry form should always be displayed in a UINavigationController.
        // The card entry form can also be pushed onto an existing navigation controller.
        let navigationController = UINavigationController(rootViewController: cardEntryForm)
        present(navigationController, animated: true, completion: nil)
    }
    
    // MARK: - SQIPCardEntryViewControllerDelegate
    
    func cardEntryViewController(_ cardEntryViewController: SQIPCardEntryViewController,
                                 didCompleteWith status: SQIPCardEntryCompletionStatus) {
        // Implemented in step 6.
        
        if status == .canceled {
            
            dismiss(animated: true, completion: nil)
            
        }
            
        else if status == .success {
            dismiss(animated: true) {
                
                self.view.endEditing(true)
                
                self.showAlert("Success!", "Your appointment has been set!",false)
                
            }
            
        }
        
    }
    
    func cardEntryViewController(_ cardEntryViewController: SQIPCardEntryViewController,
                                 didObtain cardDetails: SQIPCardDetails,
                                 completionHandler: @escaping (Error?) -> Void) {
        
        let amount = ((self.appointmentData["amount"] as! Double) + ((self.amountTipped ?? 0) * 100))
        
        let amount2 = ceil((Double(amount) * (0.029)) + 1.30)
        
        let total = Double(amount) + amount2
        
        self.appointmentData["amount"] = ceil(total/100) * 100
        
        SquareChargeApi.processPayment(nonce: cardDetails.nonce
            , amount: self.appointmentData["amount"] as! Double, key: UUID().uuidString, OAuthToken: barber.OAuthToken!, isSubscribed: self.barbershop.isSubscribed!, completion: {(transactionResult,transactionErrors,networkError) in
                
                //networking error
                if networkError != nil {
                    
                    completionHandler(networkError)
                    
                }
                    //transactionError
                else if transactionErrors != nil {
                    
                    let error:Error = paymentError.UhOh
                    
                    completionHandler(error)
                }
                    //successful transaction
                else {
                    
                    //mark the time that this appointment was created on.
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MM/dd/yyyy, HH:mm"
                    
                    self.appointmentData["transactionId"] = transactionResult!["transactionId"]
                    self.appointmentData["locationId"] = transactionResult!["locationId"]
                    self.appointmentData["tenderId"] = transactionResult!["tenderId"]
                    
                    //make sure the apppointment has not already passed.
                    guard Date() < dateFormatter.date(from: (self.appointment?.time)!)! else {
                        
                        SquareChargeApi.processRefund(transactionId: self.appointmentData["transactionId"] as! String, locationId: self.appointmentData["locationId"] as! String, tenderId: self.appointmentData["tenderId"] as! String, amount: self.appointmentData["amount"] as! Double, key: UUID().uuidString, OAuthToken: self.barber.OAuthToken!, completion: { (success, failure) in
                            
                            if failure != nil {
                                
                                let error = paymentError.refundError
                                
                                completionHandler(error)
                                
                            }
                                
                            else {
                                
                                let error = paymentError.tooLate
                                completionHandler(error)
                                
                            }
                            
                        })
                        
                        return
                    
                    }
                    
                    self.appointmentData["createdOn"] = dateFormatter.string(from: Date())
                    
                    //set the appointment
                    AppointmentService.makeAppointment(appointmentData: &self.appointmentData)
                    
                    //clear the selectedTime key from local storage and the database
                    TimeService.clearSelectedTimeKey(timeId: LocalStorageService.loadAppointmentTimeKey()!)
                    
                    //make a local notifications and end the function
                    let oneHourNotification = Notification(identifier: self.appointmentData["appointmentId"]!! as! String, body: "Your appointment with \((self.appointment?.barberName)!) is in 1 Hour.", date: (self.appointment?.timeToDate)!, remindOn: 60)
                    
                    let  thirtyMinuteNotification = Notification(identifier: self.appointmentData["appointmentId"]!! as! String, body: "Your appointment with \((self.appointment?.barberName)!) is in 30 Minutes.", date: (self.appointment?.timeToDate)!, remindOn: 30)
                    
                    let futureNotification = Notification(identifier: self.appointmentData["appointmentId"]!! as! String, body: "Want to look even more beautiful? Make an appointment at a barbershop or salon near you, they will not let you down :)", date: (self.appointment?.timeToDate)!, remindOn: 60)
                    
                    NotificationService.makeNotifications(notifications: [oneHourNotification,thirtyMinuteNotification])
                    
                    //future notification
                    NotificationService.makeFutureNotifications(notifications: [futureNotification], daysToAdd: 15)
                    
                    //appointment and transaction made successfully.
                    completionHandler(nil)
                    
                }
        })
        
    } //end of  didObtain cardDetails
} //end of extension






