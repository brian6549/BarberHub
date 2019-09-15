//
//  PricesViewController2.swift
//  Erik Barbershop App
//
//  Created by Brian on 6/18/19.
//  Copyright © 2019 Brian. All rights reserved.
//

import UIKit
///The view controller that presents the barbershop's current prices
class PricesViewController2: PricesViewController {
    
    /// The prices before they were changed
    var originalPrices:[[String:Int]]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //get the barbershop's prices from the server
        BarbershopService.getBarbershopPrices(for: (LocalStorageService.loadCurrentManager()?.barbershopId)!) { (data) in
            
            self.prices = data
            self.tableView.reloadData()
           
        }
        
    }
    
    override func continueTapped(_ sender: Any) {

        //barbershop must have at least one price in order to continue
        guard !prices.isEmpty else {
         
            showAlert(title: "Error", "You must have at least 1 item/service.")
            
            return
            
        }
        
        //update the prices in the server and dismiss the view controller
        BarbershopService.setBarbershopPrices(for: (LocalStorageService.loadCurrentManager()?.barbershopId)!, prices: prices)
 
        
        dismiss(animated: true, completion: nil)
        
    }
    
    override func dismissTapped(_ sender: Any) {
    
        dismiss(animated: true, completion: nil)
        
    }

}
