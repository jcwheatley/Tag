//
//  User.swift
//  ChatApp
//
//  Created by Gavin Robertson on 1/24/17.
//  Copyright © 2017 Gavin Robertson. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

struct User {
    let itemRef:FIRDatabaseReference?
    let uid:String
    let email:String
    let username:String
    let facebookID:String
    let profilePicture:String
    let userEvents: [String]
    let taggedEvents: [String]
    let settings: Settings
    let friends: [String]
    
    init (snapshot:FIRDataSnapshot) {
        
        itemRef = snapshot.ref
        
        let snapshotValue = snapshot.value as? NSDictionary
        if let uid = snapshotValue!["uid"] as? String{
            self.uid = uid
        }else {
            self.uid = ""
        }
        
        if let email = snapshotValue!["email"] as? String{
            self.email = email
        }else {
            self.email = ""
        }
        
        if let username = snapshotValue!["username"] as? String{
            self.username = username
        }else {
            self.username = ""
        }
        
        if let profilePicture = snapshotValue!["profilePicture"] as? String{
            self.profilePicture = profilePicture
        }else {
            self.profilePicture = ""
        }
        self.userEvents = []
        self.taggedEvents = []
        self.settings = Settings()
        self.friends = []
        self.facebookID = ""
    }
    init (uid:String, email:String, username:String, profilePicture:String) {
        self.uid = uid
        self.email = email
        self.username = username
        self.facebookID = ""
        self.profilePicture = profilePicture
        self.userEvents = []
        self.taggedEvents = []
        self.settings = Settings()
        self.friends = []
        self.itemRef=nil
    }
    func toAnyObject() -> NSDictionary {
        
        return ["uid":uid, "email":email, "username":username, "profilePicture":profilePicture]
        
    }
    
}
