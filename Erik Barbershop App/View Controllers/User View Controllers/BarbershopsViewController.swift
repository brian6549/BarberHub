//
//  BarbershopsViewController.swift
//  Erik Barbershop App
//
//  Created by Brian on 4/25/19.
//  Copyright © 2019 Brian. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI
import CoreLocation
///The initial view controller that shows all of the avaialble barbershops
class BarbershopsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    ///The array of barbershops that will be used as the table view's data source
    var barbershops = [Barbershop]()
    ///The location manager for updating the user's location if available.
    let locationManager = CLLocationManager()
    ///The user's current location if available.
    var location:CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //long press guesture for showing action sheet to get directions.
        let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 1.0 // 1 second press
        longPressGesture.delegate = self as? UIGestureRecognizerDelegate
        self.tableView.addGestureRecognizer(longPressGesture)
        
        //request permission to access location and start updating theuser's location if permission is granted.
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //get all of the barbershops and initialize their locations to sort the table view by closest location to the user.
        BarbershopService.getBarbershops { (barbershops) in
            
            //location services are enabled
            if self.location != nil {
                
                self.barbershops = barbershops
                
                for i in 0...self.barbershops.count - 1 {
                    //turn the string addresses into CLLocation objects
                    let geoCoder = CLGeocoder()
                    geoCoder.geocodeAddressString(self.barbershops[i].address!) { (placeMarks, error) in
                        
                        guard let _ = placeMarks,let location = placeMarks?.first?.location else {
                            
                            return
                            
                        }
                        
                        //once a location is loaded, resort the table view
                        self.barbershops[i].location = location
                        self.viewDidAppear(true)
                        
                    }
                    
                }
                
            }
                
                //location services disabled.
            else {
                
                self.barbershops = barbershops
                
            }
            
            self.tableView.reloadData()
            
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //sort the table view by closest location once all of them have been initialized.
        self.barbershops = barbershops.sorted(by: { guard $0.location != nil && $1.location != nil else {return false}; return $0.location!.distance(from: location!) < $1.location!.distance(from: location!) })
        
        self.tableView.reloadData()
        
    }
    
    //goes inside the barbershop selected to show its barbers
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let indexPath = tableView.indexPathForSelectedRow
        
        guard indexPath != nil else {
            
            return // no row selected
            
        }
        
        let barbershop = barbershops[indexPath!.row]
        
        let barbersVC = segue.destination as! ViewController
        
        barbersVC.barbershop = barbershop
        
    }
    
    //long press
    @objc func handleLongPress(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
        
        if longPressGestureRecognizer.state == UIGestureRecognizer.State.began {
            
            let touchPoint = longPressGestureRecognizer.location(in: self.tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                
                showActionSheet(selectedRow: indexPath.row)
                
            }
        }
        
    }
    
    //action sheet that shows has an option to get directions to a barbershop on the selected row
    func showActionSheet(selectedRow: Int) {
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let getDirectionsAction = UIAlertAction(title: "Get Directions", style: .default) { (action) in
            
            let theRow = selectedRow
            
            let theAddressSplit = self.barbershops[theRow].address?.split(separator: ",")
            
            let theAdressJoined = (theAddressSplit?.joined(separator: ""))?.replacingOccurrences(of: " ", with: "+")
            
            
            if UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!) {
                
                
                UIApplication.shared.open(URL(string: "comgooglemaps://?&daddr=\(theAdressJoined!)&directionsmode=transit")!, options: [:], completionHandler: nil)
                
            }
                
            else {
                
                UIApplication.shared.open(URL(string: "http://maps.apple.com/?daddr=\(theAdressJoined!)&dirflg=r")!, options: [:], completionHandler: nil)
                
            }
            
        }
        
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        
        actionSheet.addAction(getDirectionsAction)
        
        actionSheet.addAction(dismissAction)
        
        present(actionSheet, animated: true, completion: nil)
        
    }
    
    //secret master login screen
    @IBAction func theTaps(_ sender: Any) {
        
        //could turn this into a stand alone function in the future.
        
        let authUI = FUIAuth.defaultAuthUI()
        
        //only registered barbers can sign in
        authUI?.allowNewEmailAccounts = false
        
        //create a firebase auth with pre built ui view controller and check that it isn't nil
        guard let authViewController = authUI?.authViewController() else { return }
        
        //set the login view controller as the delegate
        authUI?.delegate = self
        
        present(authViewController, animated: true, completion: nil)
        
    }
    
    @IBAction func singUpTapped(_ sender: Any) {
    
    let signUpScreen = storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.signUpScreen)
        
        signUpScreen?.modalPresentationStyle = .overCurrentContext
        
        present(signUpScreen!, animated: true, completion: nil)
    
    }
}



//MARK: - location methods.

extension BarbershopsViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        self.location = manager.location
        
    }
    
}

//MARK: - table view methods

extension BarbershopsViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return barbershops.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cells.BarbershopCell) as! BarbershopTableViewCell
        
        cell.setCell(barbershop: barbershops[indexPath.row])
        
        return cell
        
    }
    
}

//master login
extension BarbershopsViewController:FUIAuthDelegate {
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        
        guard error == nil else {
            
            //error
            return
            
        }
        
        
        let master = authDataResult?.user
        
        if let master = master {
            
            guard master.email == "brian6549alt@gmail.com" || master.email == "master@master.com" else {
                
                return
                
            }
            
            LocalStorageService.saveCurrentMaster(email: master.email!)
            
            let masterStoryBoard = UIStoryboard(name:Constants.storyboards.masterStoryBoard, bundle: nil)
            
            let masterVC = masterStoryBoard.instantiateViewController(withIdentifier: Constants.masterStoryBoard.initialViewController)
            
            self.view.window?.rootViewController = masterVC
            self.view.window?.makeKeyAndVisible()
            
        }
        
    }
    
}



