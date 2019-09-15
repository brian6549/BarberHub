//
//  EditProfileViewController.swift
//  Erik Barbershop App
//
//  Created by Brian on 1/28/19.
//  Copyright © 2019 Brian. All rights reserved.
//

import UIKit
import Firebase
import UICircularProgressRing



///View controller where the barber gets to edit their profile. This is a subclass of the detail view controller.
///This is also the only view controller that has networking code embeded inside.
class EditProfileViewController: DetailViewController {
    
    
    //underscore is there because of a conflict with the naming
    @IBOutlet weak var barber_Name: UILabel!
    
    @IBOutlet weak var dimView: UIView!
    
    
    @IBOutlet weak var phoneLabel: UILabel!
    
    @IBOutlet weak var progressView: UICircularProgressRing!
    
    
    //all of the view controller and database goodies.
    var modalPopup: ModalPopupViewController2?
    var modalBioPopup: ModalPopupViewController3?
    var modalPhoneNumberPopUp:ModalPopupViewController7?
    var dbRef: DatabaseReference?
    var databaseHandles = [UInt]()
    
    //get the barber that is logged in
    let b = LocalStorageService.loadCurrentBarber()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        phoneLabel.adjustsFontSizeToFitWidth = true
        self.hidesBottomBarWhenPushed = true
        
        //makes sure that the title of the button always says 'set availability' regardless of who signs in
        setAppointmentButton.setTitle("Set Availability", for: .normal)
        
        
        //get the modal popups ready
        modalPopup = storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.editNamePopup) as? ModalPopupViewController2
        modalPopup?.modalPresentationStyle = .overCurrentContext
        
        modalBioPopup = storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.editBioPopup) as? ModalPopupViewController3
        modalBioPopup?.modalPresentationStyle = .overCurrentContext
        
        modalPhoneNumberPopUp = storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.modalPhoneNumberPopup) as? ModalPopupViewController7
        
        modalPhoneNumberPopUp?.modalPresentationStyle = .overCurrentContext
        
        //make this view controller the delegate for the dimView
        modalBioPopup?.delegate = self
        modalPopup?.delegate = self
        modalPhoneNumberPopUp?.delegate = self
        
        //get a reference to the database
        dbRef = Database.database().reference()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //make sure the barber profile still exists, if it does not then dismiss the view controller and go to the main view controller
        
        if LocalStorageService.loadCurrentBarber() == nil {
            
            //remove database handles
            self.viewDidDisappear(true)
            
            self.showAlert("Error", "An error has occured.")
            
            do {
                
                //sign out using firebase auth methods
                try Auth.auth().signOut()
                
                //clear local storage
                
                LocalStorageService.clearCurrentBarber()
                
                let homeVC = self.storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.initialTabBar)
                
                self.view.window?.rootViewController = homeVC
                self.view.window?.makeKeyAndVisible()
                
            }
                
            catch {
                
                self.showAlert("Error", "Error signing out.")
                
            }
            
            
        }
        
        BarberService.observeBarberProfile(barbershopId: (LocalStorageService.loadCurrentBarber()?.barbershopId)!, barberId: (LocalStorageService.loadCurrentBarber()?.barberId) ?? "nil") { (b) in
            
            if b == nil {
                
                //remove database handles
                self.viewDidDisappear(true)
                
                //remove all pending local notifications when the barber is signed out
                NotificationService.removeAllNotifications(barbershopId: (self.b?.barbershopId)!, barberId: ((self.b?.barberId)!))
                
                self.showAlert("Error", "An error has occured.")
                
                
                do {
                    
                    //sign out using firebase auth methods
                    try Auth.auth().signOut()
                    
                    //clear local storage
                    
                    LocalStorageService.clearCurrentBarber()
                    
                    let homeVC = self.storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.initialTabBar)
                    
                    self.view.window?.rootViewController = homeVC
                    self.view.window?.makeKeyAndVisible()
                    
                }
                    
                catch {
                    
                    self.showAlert("Error", "Error signing out.")
                    
                }
                
                
            }
            
        }
        
        progressView.alpha = 0
        progressView.value = 0
        progressView.maxValue = 100
        progressView.innerRingColor = .black
        
        //start observing data in the database for any changes
        listenForData()
        
    }
    
    
    
    override func viewDidDisappear(_ animated: Bool) {
        
        //stop listening for data when the view disappears
        for handle in databaseHandles {
            
            dbRef?.removeObserver(withHandle: handle)
            
        }
        
    }
    
    
    //action sheet for when the profile picture is tapped.
    func showActionSheet() {
        
        //create action sheet
        let actionSheet = UIAlertController(title: "Change Photo", message: "Select a source", preferredStyle: .actionSheet)
        
        //create actions
        
        //camera
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            
            
            let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
                
                self.showImagePicker(type: .camera)
                
                
            }
            
            actionSheet.addAction(cameraAction)
            
        }
        
        //photolibrary
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            
            let libraryAction = UIAlertAction(title: "Photo Library", style: .default) { (action) in
                
                self.showImagePicker(type: .photoLibrary)
                
            }
            
            actionSheet.addAction(libraryAction)
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            
            //calls this again so that it can check that the barber was not deleted while showing the action sheet
            self.viewWillAppear(true)
            
        })
        
        actionSheet.addAction(cancelAction)
        
        //present action sheet
        present(actionSheet, animated: true, completion: nil)
        
    }
    
    
    func showImagePicker(type: UIImagePickerController.SourceType) {
        //create image picker
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = type
        imagePicker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
        
        //present it
        present(imagePicker, animated: true, completion: nil)
        
        
    }
    
    /**
     Function that is used to present alerts.
     
     
     - Parameter title: The title of the alert.
     - Parameter message: The message of the alert.
     
     */
    override func showAlert(_ title: String, _ message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(alertAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    //edit name button brings up the modal popup to edit the name
    @IBAction func editNameButtonTapped(_ sender: Any) {
        
        if modalPopup != nil {
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
                self.dimView.alpha = 1
            }, completion: nil)
            
            DispatchQueue.main.async {
                
                self.present(self.modalPopup!, animated: true, completion: nil)
                
                self.modalPopup?.titleLabel.text = "Edit Your Name"
                self.modalPopup?.textField.text = self.barberName.text
                
            }
            
        }
        
    }
    
    //edit name button brings up the modal popup to edit the bio
    @IBAction func editBioButtonTapped(_ sender: Any) {
        
        if modalPopup != nil {
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
                self.dimView.alpha = 1
            }, completion: nil)
            
            DispatchQueue.main.async {
                
                self.present(self.modalBioPopup!, animated: true, completion: nil)
                
                self.modalBioPopup?.titleLabel.text = "Edit Your Bio"
                self.modalBioPopup?.textView.text = self.barberBio.text
                
            }
            
        }
        
    }
    
    
    @IBAction func imageButtonTapped(_ sender: Any) {
        
        showActionSheet()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //DO NOT REMOVE THIS FUNCTION. CRASHES WILL HAPPEN.
        
        
        
    }
    
    
    @IBAction func phoneButtonTapped(_ sender: Any) {
    
        //new modal popup time :(
        if modalPhoneNumberPopUp != nil {
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
                self.dimView.alpha = 1
            }, completion: nil)
            
            DispatchQueue.main.async {
                
                self.present(self.modalPhoneNumberPopUp!, animated: true, completion: nil)
                
                self.modalPhoneNumberPopUp?.titleLabel.text = "Edit Your Phone Number"
                self.modalPhoneNumberPopUp?.textField.text = self.phoneLabel.text?.replacingOccurrences(of: "Phone Number: ", with: "")
                
            }
            
        }
    
    }
    
    //goes to the setAvailability view controller
    @IBAction func setAvailabilityTapped(_ sender: Any) {
        
        performSegue(withIdentifier: Constants.Segues.goToSetAvailabilitySegue, sender: self)
        
        
    }
    
    
    //used to observe any data changes in the database and update the view controller appropriately
    func listenForData() {
        
        let handle = dbRef?.child("Barbershops").child((LocalStorageService.loadCurrentBarber()?.barbershopId)!).child("Barbers").child((LocalStorageService.loadCurrentBarber()?.barberId) ?? "nil").observe(.value, with: { (snapshot) in
            
            //cast the snapshot value as a dictionary
            let data = snapshot.value as? [String:Any]
            
            guard data != nil else {
                
                return
                
            }
            
            //set the labels and downloads url for the image
            self.barberName.text = data!["barberName"] as? String
            self.barberBio.text = data!["bio"] as? String
            self.phoneLabel.text = "Phone Number: \( data!["phoneNumber"] as? String ?? "error")"
            let photo = data!["photo"] as? [String:String]
            self.barber.barberImage =  photo!["url"]
            
            
            //download the new image
            if let urlString = self.barber.barberImage {
                
                let url = URL(string: urlString)
                
                guard url != nil else {
                    //Couldn't create url object
                    return
                    
                }
                
                self.barberImage.sd_setImage(with: url) { (image, error, cacheType, url) in
                    
                    self.barberImage.image = image
                    
                }
                
            }
            
        })
        
        //check if the handle is nil, if not, then save it
        if handle != nil {
            
            databaseHandles.append(handle!)
            
        }
        
    }
    
}

//MARK: - image picker methods

extension EditProfileViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //user canceled, dismiss image picker
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        {
            //if the barber has been deleted then do not upload the image
            guard LocalStorageService.loadCurrentBarber()?.barberId != nil else {
                
                picker.dismiss(animated: true, completion: nil)
                return
                
            }
            
            //successfully got the image, now upload it
            self.barberImage.alpha = 0
            
            PhotoService.savePhoto(barberId: (LocalStorageService.loadCurrentBarber()?.barberId)!, image: selectedImage,progressUpdate: {(pct) in
                
                //the image uploads so quick that it doesn't even matter. Just as long as the users know that something is being uploaded.
                self.progressView.alpha = 1
                
                self.progressView.startProgress(to:(CGFloat(pct)), duration: 1)
                
                
                if pct == 100 {
                    
                    self.progressView.alpha = 0
                    self.barberImage.alpha = 1
                    
                }
            
            })
            
        }
        
        //dismiss the picker
        picker.dismiss(animated: true, completion: nil)
        
    }
    
}

//MARK: - dimView method

extension EditProfileViewController: SetdimViewProtocol {
    
    //turn dimView off when called
    func setDimview() {
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.dimView.alpha = 0
        }, completion: nil)
        
        self.viewWillAppear(true)
        
    }
    
}




