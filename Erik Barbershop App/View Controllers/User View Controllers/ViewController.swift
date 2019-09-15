//
//  ViewController.swift
//  Erik Barbershop App
//
//  Created by Brian on 1/21/19.
//  Copyright © 2019 Brian. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI


///The second main view controller and the view controller that everyone will see coming from the initial one.(shows all the barbers in the selected barbershop)
class ViewController: UIViewController {
    
    
    ///navigation  bar used for changin the title depending on what kind of establishment the user goes into.
    @IBOutlet weak var navBar: UINavigationBar!
    
    ///login button
    @IBOutlet weak var loginButton: UIButton!
    
    //the table view that will show all of the barbers
    @IBOutlet weak var tableView: UITableView!
    
    //the array of barber objects that the table view will use as its data source
    var barbers = [Barber]()
    //the corresponding object of the currently selected barbershop
    var barbershop = Barbershop()
    
    var signUpVC:NewBarberViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //become the data source and delegate for the table view
        tableView.dataSource = self
        tableView.delegate = self
        
        //set the login button and navigation bar title based on the type of establishment
        navBar.topItem?.title = barbershop.establishmentType == "Barbershop" ? "Barbers": "Salon"
        
        loginButton.setTitle(barbershop.establishmentType == "Barbershop" ? "Barber Login": "Login", for: .normal)
        
        signUpVC = storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.newBarberScreen) as? NewBarberViewController
        
        signUpVC?.modalPresentationStyle = .overCurrentContext
       

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //get all of the barbers from the database
        BarberService.getBarbers(for: barbershop.barbershopId!) { (barbers) in
            
            self.barbers = barbers.shuffled() //will eventually have it so that everyone is sorted by rating
            self.tableView.reloadData()
            
        }
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let indexPath = tableView.indexPathForSelectedRow
        
        guard indexPath != nil else {
            
            //no row selected
            return
            
        }
        
        //view controller that the user sees when they tap on a barber cell
        let detailVC = segue.destination as? DetailViewController
        
        //pass the barber object of the selected barber to the next view controller
        
        let barber = barbers[indexPath!.row]
        
        //pass the barber object to the next view controller
        detailVC?.barber = barber
        detailVC?.barbershop = barbershop
        
    }
    
    
    //when the login button is tapped...
    @IBAction func loginTapped(_ sender: Any) {
        
        //performs segue
        signUpVC?.barbershop = self.barbershop
        
        guard signUpVC != nil else { return }
        
        present(signUpVC!, animated: true, completion: nil)
        
    }
    
    /**
     Function that is used to present alerts.
     
     - Parameter title: The title of the alert.
     - Parameter message: The message of the alert.
     
     */
    func showAlert(_ title: String, _ message:String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(alertAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    @IBAction func dismissButtonTapped(_ sender: Any) {
    
        dismiss(animated: true, completion: nil)
    
    }
    
}

//MARK: - table view methods

extension ViewController:UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return barbers.count //return the count of the barbers array
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Get a barber cell
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cells.barberCell, for: indexPath) as! BarberCell
        
        // Get the barber for this row
        let barber = barbers[indexPath.row]
        
        // Set the details for the cell
        cell.setBarber(barber, isClosed: barbershop.isClosed)
        
        return cell
    }
    
}









