//
//  EditBarbershopProfileViewController.swift
//  Erik Barbershop App
//
//  Created by Brian on 4/28/19.
//  Copyright © 2019 Brian. All rights reserved.
//

import UIKit
import Firebase

///The view controller where the manager can edit barbershop details.
class EditBarbershopProfileViewController: EditProfileViewController {
    
    
    @IBOutlet weak var addressLabel: UILabel!
    
    
    @IBOutlet weak var setPricesButton: UIButton!
    
    //variables and view controllers
    var hourPickerView:HoursViewController2?
    var setAvailabilityView:SetAvailabilityViewController2?
    var modalPopUp4:ModalPopupViewController4?
    var modalPopUp6:ModalPopupViewController6?
    var pricesViewController2:PricesViewController2?
    var hoursOpen:[String]?
    var prices:[[String:Int]]?
    
    override func viewDidLoad() {
        
        //setup: instantiate view controllers and give buttons rounded corners
        
        //makes sure that the title of the button always says 'set availability' regardless of who signs in
        setAppointmentButton.setTitle("Set Availability", for: .normal)
        
        setAppointmentButton.layer.cornerRadius = 10
        setAppointmentButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        setPricesButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        setPricesButton.layer.cornerRadius = 10
        
        barberBio.adjustsFontSizeToFitWidth = true
        
        hourPickerView = self.storyboard?.instantiateViewController(withIdentifier: Constants.managerStoryBoard.setHoursViewController) as?  HoursViewController2
        
        hourPickerView?.modalPresentationStyle = .overCurrentContext
        
        modalPopUp4 = self.storyboard?.instantiateViewController(withIdentifier: Constants.managerStoryBoard.setBarbershopNameVC) as? ModalPopupViewController4
        
        modalPopUp4?.modalPresentationStyle = .overCurrentContext
        
        modalPopUp4?.delegate = self
        
        modalPopUp6 = self.storyboard?.instantiateViewController(withIdentifier: Constants.managerStoryBoard.modalPopUpViewController6) as? ModalPopupViewController6
        
        modalPopUp6?.modalPresentationStyle = .overCurrentContext

        modalPopUp6?.delegate = self
        
        setAvailabilityView = self.storyboard?.instantiateViewController(withIdentifier: Constants.managerStoryBoard.setBarbershopAvailabilityVC) as? SetAvailabilityViewController2
        
        setAvailabilityView?.modalPresentationStyle = .overCurrentContext
        
        pricesViewController2 = self.storyboard?.instantiateViewController(withIdentifier: Constants.managerStoryBoard.setPricesViewController) as? PricesViewController2
        pricesViewController2?.modalPresentationStyle = .overCurrentContext
        
        barberBio.adjustsFontSizeToFitWidth = true
        
        addressLabel.adjustsFontSizeToFitWidth = true
        
        //get a reference to the database
        dbRef = Database.database().reference()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        listenForData()
        
    }
  
    //MARK: - modal popups
    
    override func editNameButtonTapped(_ sender: Any) {
        
        if modalPopUp4 != nil {
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
                self.dimView.alpha = 1
            }, completion: nil)
            
            DispatchQueue.main.async {
                
                self.present(self.modalPopUp4!, animated: true, completion: nil)
                self.modalPopUp4?.titleLabel.text = "Edit Establishment Name"
                self.modalPopUp4?.textField.text = self.barberName.text
                
            }
            
        }
        
    }
    
    override func editBioButtonTapped(_ sender: Any) {
        
        if hourPickerView != nil {
            
            DispatchQueue.main.async {
                
                self.present(self.hourPickerView!, animated: true, completion: nil)
                let timeFormat = DateFormatter()
                
                timeFormat.dateFormat = "h:mm a"
                self.hourPickerView?.datePicker1.date = timeFormat.date(from: self.hoursOpen![0])!
                self.hourPickerView?.datePicker2.date = timeFormat.date(from: self.hoursOpen![1])!
                
            }
            
        }
        
    }
    
    
    @IBAction func adressButtonTapped(_ sender: Any) {
        
        //brings up popup to change the address
        if modalPopUp6 != nil {
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
                self.dimView.alpha = 1
            }, completion: nil)
            
            
            DispatchQueue.main.async {
                
                self.present(self.modalPopUp6!, animated: true, completion: nil)
                self.modalPopUp6?.titleLabel.text = "Edit Establishment Adress"
                self.modalPopUp6?.textField.text = self.addressLabel.text?.replacingOccurrences(of: "Address: ", with: "")
                
            }
            
        }
        
    }
    
    
    @IBAction func setPricesTapped(_ sender: Any) {
        
        //brings up the view controller that allows the manager to set the prcies in the barbershop
        
        DispatchQueue.main.async {
            
            
            self.present(self.pricesViewController2!, animated: true, completion: nil)
          
        }
    
    }
    
    
    //used to observe any data changes in the database and update the view controller appropriately
    override func listenForData() {
        
        let handle = dbRef?.child("Barbershops").child(((LocalStorageService.loadCurrentManager()?.barbershopId)!)).observe(.value, with: { (snapshot) in
            
            //cast the snapshot value as a dictionary
            let data = snapshot.value as? [String:Any]
            
            guard data != nil else {
                
                return
                
            }
            
            //set the labels and download url for the image
            self.barberName.text = data!["name"] as? String
            let hoursOpen = data!["hoursOpen"] as? [String]
            self.hoursOpen = hoursOpen
            self.barberBio.text = "Open: \(hoursOpen![0]) - \(hoursOpen![1])"
            self.addressLabel.text = "Address: \(data!["address"] as? String ?? "address")"
    
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
    
    override func setAvailabilityTapped(_ sender: Any) {
        
        //performs segue
        
    }
    
    
    
    //image picker override
    override func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        {
            //if the barber has been deleted then do not upload the image
            guard LocalStorageService.loadCurrentManager()?.barbershopId != nil else {
                
                picker.dismiss(animated: true, completion: nil)
                
                return
                
            }
            
            //successfully got the image, now upload it
            
            self.barberImage.alpha = 0
            PhotoService.savePhoto(barbershopId: (LocalStorageService.loadCurrentManager()?.barbershopId)!, image: selectedImage,progressUpdate: {(pct) in
                
                self.progressView.alpha = 1
                
                self.progressView.startProgress(to: (CGFloat(pct)), duration: 1)
                
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
