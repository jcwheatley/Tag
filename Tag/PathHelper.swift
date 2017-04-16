//
//  PathHelper.swift
//  Tag
//
//  Created by Gavin Robertson on 4/14/17.
//  Copyright © 2017 Tag Along. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class PathHelper{
    var dbRefEvents:FIRDatabaseReference!
    var dbRefUser:FIRDatabaseReference!
    var storageRef:FIRStorageReference!
    let profilePicStoragePath = "Images/ProfileImage/"
    let eventPicStoragePath = "Images/EventImage/"
    let storage = FIRStorage.storage()
    let currentUserFIR = FIRAuth.auth()?.currentUser
    
    init(){
        dbRefEvents = FIRDatabase.database().reference().child("events")
        dbRefUser = FIRDatabase.database().reference().child("users")
        storageRef = storage.reference(forURL: "gs://tag-along-6c539.appspot.com")
    }
}
