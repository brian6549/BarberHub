//
//  AppDelegate.swift
//  Erik Barbershop App
//  Created on 1/21/19
//  Created by Brian Arias.
//  Copyright © 2019 Brian Arias. All rights reserved.
//  Developed and tested in Brooklyn, NY, USA 🇺🇸

import UIKit
import UserNotifications
import NotificationCenter
import Firebase
import SquareInAppPaymentsSDK
import CoreLocation


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    //MARK: - variables to be used during launch
    
    ///window that will be used to show the appointments view controller if the barber is signed in
    var window: UIWindow?
    
    //if the user was making an appointment and then quits the app in the middle of it or something happens, this will be used to clear the selected time from the database so that everyone can choose it again if it has not already passed
    var selectedTimeKey:String?
    
    //the manager used to ask for permission to use a user's location.
    let locationManager = CLLocationManager()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //MARK: - network configuration
        
        //registers the app for remote push notifications
        registerForPushNotifications()
        
        self.locationManager.requestWhenInUseAuthorization()
        
        //initial app launch
        if LocalStorageService.isFirstLaunch()  {
            
            //instantiate the splash screen
            let storyBoard = UIStoryboard(name: Constants.storyboards.mainStoryBoard, bundle: .main)
            let splashScreen = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.splashScreen)
            
            //schedule a notification that will be sent every month to keep customers coming back to the app.
            let components = Calendar.current.dateComponents([.day,.hour,.minute,.second], from: Date())
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            
            let content = UNMutableNotificationContent()
            
            content.body = "No more waiting around and not knowing when your turn is at the barbershop or salon, book an appointment now and avoid the hassle :)"
            
            let request = UNNotificationRequest(identifier: "welcomeNotification", content: content, trigger: trigger)
            
            let center = UNUserNotificationCenter.current()
            center.add(request) { (error : Error?) in
                if let theError = error {
                    print(theError.localizedDescription)
                }
            }
            
            //show the splash screen
            self.window?.rootViewController = splashScreen
            self.window?.makeKeyAndVisible()
            
        }
        
        //configure the Firebase components
        FirebaseApp.configure()
        Messaging.messaging().delegate = self as? MessagingDelegate
        
        //check if a master is signed in
        
        let master = LocalStorageService.loadCurrentMaster()
        
        if master != nil {
            
            let masterStoryBoard = UIStoryboard(name: Constants.storyboards.masterStoryBoard, bundle: nil)
            
            let masterVC = masterStoryBoard.instantiateViewController(withIdentifier: Constants.masterStoryBoard.initialViewController)
            
            self.window?.rootViewController = masterVC
            self.window?.makeKeyAndVisible()
            
        }
        
        //check if a manager is signed in
        let manager = LocalStorageService.loadCurrentManager()
        
        if manager != nil {
            
            let managerStoryBoard = UIStoryboard(name: Constants.storyboards.managerStoryBoard, bundle: nil)
            let managerVC = managerStoryBoard.instantiateViewController(withIdentifier: Constants.managerStoryBoard.initialViewController) as! UITabBarController
            
            self.window?.rootViewController = managerVC
            self.window?.makeKeyAndVisible()
            
        }
        
        //load the current barber from local storage to see if there is one signed in
        let barber = LocalStorageService.loadCurrentBarber()
        
        //if there is a barber in local sotrage...
        if barber != nil {
            
            BarberService.getBarberProfile(barbershopId: (barber?.barbershopId)!, barberId: (barber?.barberId)!) { (u) in
                
                //if the barber no longer has a profile...
                if u == nil {
                    
                    LocalStorageService.clearCurrentBarber()
                    
                }
                    
                    //if the barber does have a profile...
                else {
                    
                    if u?.OAuthToken != nil {
                        
                        SquareChargeApi.renewOAuthToken(for: (u?.barberId)!, in: (u?.barbershopId)!, OAuthToken: (u?.OAuthToken)!)
                    }
                    
                    
                    //load the device token from local storage
                    let token = LocalStorageService.loadToken()
                    
                    //if this device has a token then send that to the database for notifications, else , send a blank string to the database
                    if token != nil {
                        
                        BarberService.setToken(for: (barber?.barberId)!, in: (barber?.barbershopId)!, token: token!)
                        
                    }
                        
                    else {
                        
                        BarberService.setToken(for: (barber?.barberId)!, in: (barber?.barbershopId)!, token: "")
                        
                    }
                    
                    //create an appointment view controller
                    let appointmentVC = UIStoryboard(name: Constants.storyboards.mainStoryBoard, bundle: .main).instantiateViewController(withIdentifier: Constants.Storyboard.barberTabBar)
                    
                    //show it
                    self.window?.rootViewController = appointmentVC
                    self.window?.makeKeyAndVisible()
                    
                }
                
            }
            
        }
        
        
        //MARK: - notifications and user setup 
        
        //clear any appointments that have already passed from local astorage
        LocalStorageService.clearOutdatedAppointmentKeys()
        
        //clear the icon badge number if there is a notification
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        //this is very unlikely but if the device powers off while the user is in the middle of making an appointment then this needs to happen here too. This is also for when the user quits in the middle of making an appointment or the application crashes.
        selectedTimeKey = LocalStorageService.loadAppointmentTimeKey()
        
        if selectedTimeKey != nil {
            
            
            TimeService.clearSelectedTimeKey(timeId: selectedTimeKey!)
            
            
        }
        
        //request authorization for notifications
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            // Enable or disable features based on authorization.
            
        }
        
        center.delegate = self as UNUserNotificationCenterDelegate
        
        
        SQIPInAppPaymentsSDK.squareApplicationID = "sq0idp-LAdXivOb-LNAgOSHcvqAag"
        
        return true
        
    }
    
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        //clear any appointments that have already passed from local astorage
        LocalStorageService.clearOutdatedAppointmentKeys()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
        //clear the icon badge number if there is a notification
        UIApplication.shared.applicationIconBadgeNumber = 0
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        //if the user quits midway while making an appointment, clear this selected time from the database so that others can choose
        
        selectedTimeKey = LocalStorageService.loadAppointmentTimeKey()
        
        if selectedTimeKey != nil {
            
            
            TimeService.clearSelectedTimeKey(timeId: selectedTimeKey!)
            
        }
        
        //clear any appointments that have already passed from local storage
        LocalStorageService.clearOutdatedAppointmentKeys()
        
    }
    
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            print("Permission granted: \(granted)")
            // 1. Check if permission granted
            guard granted else { return }
            // 2. Attempt registration for remote notifications on the main thread
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
        
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // 1. Convert device token to string
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        let token = tokenParts.joined()
        // 2. Print device token to use for PNs payloads
        print("Device Token: \(token)")
        
        //save the device token to local storage if the user opts in for notifications
        LocalStorageService.saveToken(token)
        
        //if the user does opt in to notifications, subscribe them to a topic whose name is their device token
        Messaging.messaging().subscribe(toTopic: token) { error in
            print("Subscribed to \(token)")
            
        }
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // 1. Print out error if PNs registration not successful
        print("Failed to register for remote notifications with error: \(error)")
        
        
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        //go the appointment view controller when a notification is tapped
        
        if LocalStorageService.loadCurrentBarber() != nil {
            
            let appointmentVC = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: Constants.Storyboard.barberTabBar) as! UITabBarController
            
            appointmentVC.selectedIndex = 0
            
            self.window?.rootViewController = appointmentVC
            
            self.window?.endEditing(true)
            
            self.window?.makeKeyAndVisible()
            
            
        }
            
        else {
            
            let appointmentVC = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: Constants.Storyboard.initialTabBar) as! UITabBarController
            
            appointmentVC.selectedIndex = 1
            
            self.window?.rootViewController = appointmentVC
            
            if let key = LocalStorageService.loadAppointmentTimeKey() {
                
                TimeService.clearSelectedTimeKey(timeId: key)
                
                LocalStorageService.clearAppointmentTimeKey()
                
            }
            
            self.window?.endEditing(true)
            
            self.window?.makeKeyAndVisible()
            
            
        }
        
        completionHandler() //finished
        
    }
    
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    //present the notification in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([UNNotificationPresentationOptions.alert,UNNotificationPresentationOptions.sound])
        
    }
    
}




