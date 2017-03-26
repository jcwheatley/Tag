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
    var email:String
    var username:String
    var facebookID:String
    var profilePicture:String
    var myEvents:[String]
    var taggedEvents: [String]
    var discardedEvents:[String]
    var settings: Settings
    var friends: [String]
    
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
        
        self.myEvents = []
        self.discardedEvents = []
        self.taggedEvents = []
        self.friends = []
        let children = snapshot.children
        for child in children{
            let data = child as! FIRDataSnapshot
            if (data.key == "taggedEvents"){
                self.taggedEvents = data.value as! [String]
            }else if(data.key == "discardedEvents"){
                self.discardedEvents = data.value as! [String]
            }else if(data.key == "friends"){
                self.friends = data.value as! [String]
            }else if(data.key == "myEvents"){
                print(username)
                print(data.value)
                self.myEvents = data.value as! [String]
            }
        }
        
        self.settings = Settings()
        
        if let username = snapshotValue!["username"] as? String{
            self.username = username
        }else {
            self.username = ""
        }
        
        if let facebookID = snapshotValue!["facebookID"] as? String{
            self.facebookID = facebookID
        }else{
            self.facebookID = ""
        }
    }
    init (uid:String, email:String, username:String, profilePicture:String) {
        self.uid = uid
        self.email = email
        self.username = username
        self.facebookID = ""
        self.profilePicture = profilePicture
        self.myEvents = []
        self.taggedEvents = []
        self.settings = Settings()
        self.friends = []
        self.discardedEvents = []
        self.itemRef=nil
    }
    func toAnyObject() -> NSDictionary {
        
        return ["uid":uid, "email":email, "username":username, "profilePicture":profilePicture, "facebookId":facebookID, "myEvents":myEvents, "taggedEvents":taggedEvents, "settings":settings, "friends":friends, "discardedEvents":discardedEvents, "itemRef":itemRef!]
        
    }
    
}
