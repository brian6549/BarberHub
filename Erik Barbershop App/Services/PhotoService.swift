//
//  PhotoService.swift
//  Erik Barbershop App
//
//  Created by Brian on 1/21/19.
//  Copyright © 2019 Brian. All rights reserved.
//

import Foundation
import Firebase

///manages photos that are uploaded to the database
class PhotoService {
    
    
    /**
     
     Gets photos sotred in the database.
     
     - Parameter completion: A closure with an array of Photo objects.
     
     */
    static func getPhotos(completion: @escaping (([Photo]) -> Void)) -> Void {
        
        //getting a reference to the database
        let dbRef = Database.database().reference()
        
        //make the database call
        dbRef.child("photos").observeSingleEvent(of: .value) { (snapshot) in
            
            var retrievedPhotos = [Photo]()
            
            //get the list of snapshots
            let snapshots = snapshot.children.allObjects as? [DataSnapshot]
            
            if let snapshots = snapshots {
                
                //loop through each snapshot and parse out the photos
                
                for snap in snapshots {
                    
                    //try to create a photo from a snapshot
                    let p = Photo(snapshot: snap)
                    
                    //if successful, then add it to our array
                    if p != nil {
                        
                        retrievedPhotos.insert(p!, at: 0)
                        
                    }
                    
                } //end of for loop
                
            } //end of if
            
            //after parsing the snapshots, call the completion closure
            completion(retrievedPhotos)
            
        } //end of closure
    } //end of function
    
    
    /**
     Saves photo into the database.
     
     - Parameter barberId: The barber Id of the barber that uploads the photo.
     - Parameter image: The image that will be uploaded.
     
     */
    static func savePhoto(barberId: String, image: UIImage, progressUpdate: @escaping (Double) -> Void) {
        
        //get data representation of the image
        let photoData = image.jpegData(compressionQuality: 0.1)
        
        //make sure the data is not nil
        guard photoData != nil else {
            
            return
            
        }
        
        //get a storage reference
        let userid = Auth.auth().currentUser!.uid
        let filename = UUID().uuidString
        
        let ref = Storage.storage().reference().child("images/\(userid)/\(filename).jpg")
        
        //upload the photo
        let uploadTask =  ref.putData(photoData!, metadata: nil) { (metadata, error) in
            
            
            if error != nil {
                
                //An error during upload occured
                return
                
            }
                
            else {
                //upload was successful, now create a database entry
                self.createPhotoDatabaseEntry(barberId: barberId, ref: ref)
                
            }
            
        } //end of closure
        
        uploadTask.observe(.progress) { (snapshot) in
            
            let percentage: Double = (Double(snapshot.progress!.completedUnitCount) / Double (snapshot.progress!.totalUnitCount)) * 100
            
            progressUpdate(percentage)
            
            
        }
        
    } //end of function
    
    /**
     Saves photo into the database.
     
     - Parameter barbershopId: The barber Id of the barber that uploads the photo.
     - Parameter image: The image that will be uploaded.
     
     */
    static func savePhoto(barbershopId:String, image:UIImage, progressUpdate: @escaping (Double) -> Void) {
        
        //get data representation of the image
        let photoData = image.jpegData(compressionQuality: 0.1)
        
        //make sure the data is not nil
        guard photoData != nil else {
            
            return
            
        }
        
        //get a storage reference
        let userid = Auth.auth().currentUser!.uid
        let filename = UUID().uuidString
        
        let ref = Storage.storage().reference().child("images/\(userid)/\(filename).jpg")
        
        //upload the photo
        let uploadTask = ref.putData(photoData!, metadata: nil) { (metadata, error) in
            
            
            if error != nil {
                
                //An error during upload occured
                return
                
            }
                
            else {
                //upload was successful, now create a database entry
                self.createPhotoDatabaseEntry(barbershopId: barbershopId, ref: ref)
                
            }
            
        } //end of closure
        
        uploadTask.observe(.progress) { (snapshot) in
            
            let percentage: Double = (Double(snapshot.progress!.completedUnitCount) / Double (snapshot.progress!.totalUnitCount)) * 100
            
            progressUpdate(percentage)
            
            
        }
        
    }
    
    
    /**
     Creates an entry in firebase storage.
     
     - Parameter barberId: The barberId that the entry belongs to.
     
     - Parameter ref: Reference to firebase storage.
     
     */
    private static func createPhotoDatabaseEntry(barberId: String, ref: StorageReference) {
        
        //get a download url for the photo
        
        ref.downloadURL { (url, error) in
            
            
            if error != nil {
                
                //Couldn't retrieve the url
                return
                
            }
                
                
            else {
                
                //get the meta data for the database entry
                
                //barber
                let barber = LocalStorageService.loadCurrentBarber()
                
                //make sure the barber is actually signed in
                guard barber != nil else {
                    
                    return
                    
                }
                
                // Date
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .full
                
                let dateString = dateFormatter.string(from: Date())
                
                //create photo data
                let photoData = ["byId": barber!.barberId!,"byUsername":barber!.barberName!, "date": dateString, "url":url!.absoluteString]
                
                //write a database entry
                
                let dbRef = Database.database().reference().child("Barbershops").child((barber?.barbershopId)!).child("Barbers").child(barberId).child("photo")
                
                dbRef.setValue(photoData, withCompletionBlock: { (error, dbRef) in
                    
                    if error != nil {
                        
                        //there was an error writing the database entry
                        return
                        
                    }
                    
                }) //end of closure for dbRef.setValue
                
            } //end of else
            
        } //end of closure for ref.downloadURL
        
    } //end of function
    
    
    
    /**
     Creates an entry in firebase storage.
     
     - Parameter barbershopId: The barbershopId that the entry belongs to.
     
     - Parameter ref: Reference to firebase storage.
     
     */
    private static func createPhotoDatabaseEntry(barbershopId: String, ref: StorageReference) {
        
        //get a download url for the photo
        
        ref.downloadURL { (url, error) in
            
            
            if error != nil {
                
                //Couldn't retrieve the url
                return
                
            }
                
            else {
                
                //get the meta data for the database entry
                
                //barber
                let manager = LocalStorageService.loadCurrentManager()
                
                //make sure the barber is actually signed in
                guard manager != nil else {
                    
                    return
                    
                }
                
                // Date
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .full
                
                let dateString = dateFormatter.string(from: Date())
                
                //create photo data
                let photoData = ["byId": manager?.barbershopId,"byUsername":manager?.managerEmail, "date": dateString, "url":url!.absoluteString]
                
                //write a database entry
                
                let dbRef = Database.database().reference().child("Barbershops").child((manager?.barbershopId)!).child("photo")
                
                dbRef.setValue(photoData, withCompletionBlock: { (error, dbRef) in
                    
                    if error != nil {
                        
                        //there was an error writing the database entry
                        return
                        
                    }
                    
                }) //end of closure for dbRef.setValue
                
            } //end of else
            
        } //end of closure for ref.downloadURL
        
        
    }
}
