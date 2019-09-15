//
//  Constants.swift
//  Erik Barbershop App
//
//  Created by Brian on 1/21/19.
//  Copyright © 2019 Brian. All rights reserved.
//

import Foundation

///named constants such as view controllers, segues and cells.
struct Constants {
    
    struct storyboards {
        
        static let mainStoryBoard = "Main"
        static let managerStoryBoard = "Manager"
        static let masterStoryBoard = "Master"
        
    }
    
    ///Contains the names of the view controllers in the storyboard.
    struct Storyboard {
        
        //view cotrollers
        
        static let initialTabBar = "BarbershopTabBar"
        static let barberTabBar = "BarberTabBar"
        static let userAppointmentViewController = "AppointmentView2"
        static let barberAppointmentViewController = "AppointmentView"
        static let initialVC = "Home"
        static let viewProfileController = "DetailViewController"
        static let editProfileViewController = "EditProfileViewController"
        static let setAppointmentVC = "SetAppointmentViewController"
        static let modalPopupViewController = "ModalPopupViewController"
        static let setAvailabilityViewController = "SetAvailabilityViewController"
        static let editNamePopup = "ModalPopupViewController2"
        static let editBioPopup = "ModalPopupViewController3"
        static let modalPhoneNumberPopup = "ModalPopupViewController7"
        static let settingsViewController = "SettingsViewController"
        static let splashScreen = "splashScreen"
        static let signUpScreen = "signUpScreen"
        static let newBarberScreen = "LoginViewController"
        
    }
    
    struct masterStoryBoard {
        
        static let initialViewController = "masterBarbershopsVC"
        static let createProfileVC = "createProfileVC"
        static let modalPopupPrices = "ModalPopupViewController5"
        static let signUpCodeScreen = "signUpCodeScreen"
        
        struct segues {
            
            static let goToAddressVC = "goToAddressVC"
            static let goToHoursVC = "goToHoursVC"
            static let goToEstablishmentVC = "goToEstablishmentVC"
            static let goToPricesVC = "goToPricesVC"
            
        }
        
        
    }
    
    struct managerStoryBoard {
        
        static let initialViewController = "managerTabBar"
        static let createBarberProfileVC = "createBarberProfileVC"
        static let setHoursViewController =  "hoursVC2"
        static let setBarbershopNameVC = "ModalPopupViewController4"
        static let setBarbershopAvailabilityVC = "SetAvailabilityViewController2"
        static let setPricesViewController = "pricesVC2"
        static let modalPopUpViewController6 = "ModalPopupViewController6"
        
        struct segues {
            
            static let goToOSVC = "goToOSVC"
            static let goToPhoneVC = "goToPhoneVC"
            static let goToSettings = "goToSettings"
            
        }
        
        
    }
    ///Contains the name of segues in the storyboard.
    struct Segues {
        
        //user segues
        static let detailViewSegue = "goToDetail"
        static let setAppointmentSegue = "goToSetAppointment"
        static let goToTabBarSegue = "goHome"
        
        //barber segues
        
        static let goToSetAvailabilitySegue = "goToAvailability"
        static let goToSettingsSegue = "goToSettings"
        
        
    }
    
    ///Contains the names of the prototype cells in the table views.
    struct Cells {
        
        static let barberCell = "BarberCell"
        static let appointmentCell = "AppointmentCell"
        static let dayCell = "DayTableViewCell"
        static let BarbershopCell = "BarbershopCell"
        static let priceCell = "haircutCell"
        static let masterPriceCell = "priceCell"
        
        
    }
    
}
