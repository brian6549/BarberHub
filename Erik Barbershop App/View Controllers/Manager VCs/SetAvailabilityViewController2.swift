//
//  SetAvailabilityViewController2.swift
//  Erik Barbershop App
//
//  Created by Brian on 4/28/19.
//  Copyright © 2019 Brian. All rights reserved.
//

import UIKit

///The view conroller where a barbershop can set their availability.
class SetAvailabilityViewController2: SetAvailabilityViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
    }
    
    override func doneTapped(_ sender: Any) {
        
        var finalArray = daysAdded
        
        for i in finalArray {
            
            
            if i == "" {
                
                finalArray.remove(at: finalArray.firstIndex(of: i)!)
                
            }
            
        }
        
        //send the new info to the database if the array is not empty
        
        if !finalArray.isEmpty {
            
            let data = finalArray.joined(separator: ",")
            
            BarbershopService.setBarbershopDays(days: data)
            showAlert("Success!","Your new days are: \(data)",false,false)
            
        }
            
        else {
            
            //no days have been chosen
            showAlert("Error","You must choose at least one day.",true,false)
            return
            
        }
        
    }
    //cellForROwAt override for managers.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //get a cell
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cells.dayCell, for: indexPath) as! DayTableViewCell
        
        //make the cell gray when it is selected
        let backgroundView = UIView()
        
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.50)
        
        cell.selectedBackgroundView = backgroundView
        
        cell.setCell(text: days[indexPath.row])
        
        //if the day is already in the databse, add it to the daysAdded array ---> only for the initial setup
        if initialStagePassed == false {
            
            let u = LocalStorageService.loadCurrentManager()
            
            BarbershopService.getBarbershopDays(barbershopId: (u?.barbershopId)!) { (day) in
                //will probably talk about the highlighting stuff in the documentation
                self.availabilityLabel.text = "Your Current Availability: " + day.joined(separator: ", ")
                
                //if the barber is already available on a specific day, then pre-select that cell
                if day.contains(Substring(self.days[indexPath.row])) && !cell.isSelected {
                    
                    tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                    self.daysAdded[indexPath.row] = self.days[indexPath.row]
                    
                }
                
            }
            
        }
        
        return cell
        
        
    }
    
}
