//
//  Photo.swift
//  Erik Barbershop App
//
//  Created by Brian on 1/21/19.
//  Copyright © 2019 Brian. All rights reserved.
//

import Foundation
import Foundation
import FirebaseDatabase

///Photo model.
struct Photo {
    
    ///The photoId
    var photoId: String?
    ///The Id of the person that uploaded the photo.
    var byId: String?
    ///The name of the person that uploaded the photo.
    var byUsername: String?
    ///The url of the photo.
    var url: String?
    
    /**
     Main initializer. Initializes a photo object using a datasnapshot.
     
     - Parameter snapshot: Datasnapshot that will be used for initialization.
     
     - Returns: nil if initialization fails.
     
     */
    init?(snapshot: DataSnapshot) {
        
        //Photo data
        let photoData = snapshot.value as? [String:String]
        
        //initialize everything and return nil if it fails
        if let photoData = photoData {
            
            let photoId = snapshot.key
            let byId = photoData["byId"]
            let byUsername = photoData["byUsername"]
            let date = photoData["date"]
            let url = photoData["url"]
            
            guard byId != nil && byUsername != nil && date != nil && url != nil else {
                
                return nil
                
            }
            
            self.photoId = photoId
            self.byId = byId
            self.byUsername = byUsername
            self.url = url
            
            
        }
        
    }
    
}
