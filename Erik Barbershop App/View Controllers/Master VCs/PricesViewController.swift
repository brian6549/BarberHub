//
//  PricesViewController.swift
//  
//
//  Created by Brian on 6/4/19.
//

import UIKit

///view controller used to set up the initial barbershop prices
class PricesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var dimView: UIView!
    
    
    @IBOutlet weak var addPriceButton: UIButton!
    
    @IBOutlet weak var confirmButton: UIButton!
    
    ///the modal popup for the user to put their name in for the appointment
    var modalPopup: ModalPopupViewController5?
    
    ///the dictionary used to store all of the prices
    var prices = [[String:Int]]()
    
    ///dictionary that contains all of the collected barbershop data.
    var barberData = [String:Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //initial table view and modal popup setup
        
        tableView.dataSource = self
        tableView.delegate = self
        
        dimView.alpha = 0
        
        let storyboard = UIStoryboard(name: Constants.storyboards.masterStoryBoard, bundle: nil)
        //get the modal popup ready
        modalPopup = storyboard.instantiateViewController(withIdentifier: Constants.masterStoryBoard.modalPopupPrices) as? ModalPopupViewController5
        //resultVC?.delegate = self
        modalPopup?.modalPresentationStyle = .overCurrentContext
        
        modalPopup?.delegate = self
        
        addPriceButton.layer.cornerRadius = 10
        confirmButton.layer.cornerRadius = 10
        
    }
    
    //MARK: - alert functions
    
    /**
        Function used to present alerts
     
        - Parameter title: the title of the alert
        - Parameter message: the message that the alert will show
        - Parameter row: the row that the alert relates to
 
 
     */
    func showAlert(_ title: String , _ message: String, _ row: Int) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "No", style: .default, handler: nil)
        
        //remove the price
        let removeAction = UIAlertAction(title: "Yes", style: .destructive) { (action) in
            
            self.prices.remove(at: row)
            self.tableView.reloadData()
            
        }
        
        alert.addAction(action)
        alert.addAction(removeAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    /**
     Function used to present alerts not relating to the table view
     
     - Parameter title: the title of the alert
     - Parameter message: the message that the alert will show
     
     */
    func showAlert(title: String, _ message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    /**
     Function that shows the action sheet when a table view cell is tapped
     
     - Parameter row: the table view row that the action sheet relates to
 
 */

    func showActionSheet(_ row: Int) {
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        //remove an item
        let removeAction = UIAlertAction(title: "Remove Item/Service", style: .destructive) { (action) in
            
            self.showAlert("Remove Item/Serivce", "Are you sure you want to remove this item/service?", row)
            
        }
        //edit an item.
        let editAction = UIAlertAction(title: "Edit Item/Service", style: .default) { (action) in
            
            
            self.modalPopup?.prices = self.prices
            
            //present the modal popup if it is not nil
            if self.modalPopup != nil {
                
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
                    self.dimView.alpha = 1
                }, completion: nil)
                
                
                DispatchQueue.main.async {
                    
                    self.present(self.modalPopup!, animated: true, completion: nil)
                    
                    //preload text on the modal popup
                    let dict = self.prices[row]
                    
                    for i in dict {
                        
                        self.modalPopup?.editingAt = row
                        self.modalPopup?.nameTextField.text = i.key
                        self.modalPopup?.priceTextField.text = String(i.value)
                        
                    }
                    
                }
                
            }
            
        }
        
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        
        actionSheet.addAction(removeAction)
        actionSheet.addAction(editAction)
        actionSheet.addAction(dismissAction)
        
        present(actionSheet, animated: true, completion: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //pass the updated data to the next view controller
        
        let establishmentVC = segue.destination as! ChooseEstablishmentVC
        
        self.barberData["prices"] = self.prices
        
        establishmentVC.barberData = self.barberData
        
    }
    
    ///present the modal popup to add a price
    @IBAction func addPriceTapped(_ sender: Any) {
        
        modalPopup?.prices = self.prices
        
        //present the modal popup if it is not nil
        if self.modalPopup != nil {
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
                self.dimView.alpha = 1
            }, completion: nil)
            
            
            DispatchQueue.main.async {
                
                self.present(self.modalPopup!, animated: true, completion: nil)
                
                
            }
            
        }
        
    }
    
    
    @IBAction func continueTapped(_ sender: Any) {
        
        //must have at least one price to continue.
        guard !prices.isEmpty else {
            
            showAlert(title: "Error", "You must have at least 1 item/service.")
            
            return
            
        }
        
    }
    
    
    @IBAction func dismissTapped(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
}

extension PricesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return prices.count //the items in the table view are based on this dictionary
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cells.masterPriceCell) as! PricesTableViewCell
        
        //make the cell gray when it is selected
        let backgroundView = UIView()
        
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.50)
        
        cell.selectedBackgroundView = backgroundView
        //set the price cell
        cell.setPriceCell(with: prices[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //show action sheet when selected
        showActionSheet(indexPath.row)
        
    }
    
    //also need an option to remove prices
    func  tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let action = UITableViewRowAction(style: .destructive, title: "Remove") { (action, indexPath) in
            
            self.showAlert("Remove Item/Serivce", "Are you sure you want to remove this item/service?", indexPath.row)
            
        }
        
        return [action]
        
    }
    
}

extension PricesViewController: SetdimViewProtocol {
    
    func setDimview() {
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.dimView.alpha = 0
        }, completion: nil)
        
        //refresh the table view to update the prices
        self.prices = modalPopup?.prices ?? self.prices
        self.tableView.reloadData()
        
    }
    
}
