//
//  Event.swift
//  Tag
//
//  Created by Gavin Robertson on 2/18/17.
//  Copyright © 2017 Tag Along. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

struct Event {
    let itemRef:FIRDatabaseReference?
    let eventName:String
    let time:String
    let owner:String
    let location:String
    let eventSummary:String
    let privateEvent:Bool
    let eventPicture:String
    let taggedUsers: [String]
    
    init (snapshot:FIRDataSnapshot) {
        
        itemRef = snapshot.ref
        
        let snapshotValue = snapshot.value as? NSDictionary
        if let eventName = snapshotValue!["eventName"] as? String{
            self.eventName = eventName
        }else {
            self.eventName = ""
        }
        
        if let owner = snapshotValue!["owner"] as? String{
            self.owner = owner
        }else {
            self.owner = ""
        }
        
        if let eventSummary = snapshotValue!["eventSummary"] as? String{
            self.eventSummary = eventSummary
        }else {
            self.eventSummary = ""
        }
        
        if let location = snapshotValue!["location"] as? String{
            self.location = location
        }else {
            self.location = ""
        }
        
        if let time = snapshotValue!["location"] as? String{
            self.time = time
        }else {
            self.time = ""
        }
        
        if let privateEvent = snapshotValue!["privateEvent"] as? Bool{
            self.privateEvent = privateEvent
        }else {
            self.privateEvent = false
        }
        
        if let eventPicture = snapshotValue!["eventPicture"] as? String{
            self.eventPicture = eventPicture
        }else {
            self.eventPicture = ""
        }
        self.taggedUsers = []
    }
    init (eventName:String, owner:String, eventSummary:String, location:String, privateEvent:Bool, eventPicture:String, time:String) {
        self.eventName = eventName
        self.owner = owner
        self.eventSummary = eventSummary
        self.location = location
        self.privateEvent = privateEvent
        self.eventPicture = eventPicture
        self.time = time
        self.taggedUsers = []
        self.itemRef = nil
    }
    func toAnyObject() -> NSDictionary {
        
        return ["eventName":eventName, "owner":owner, "eventSummary":eventSummary, "location":location, "privateEvent":privateEvent, "eventPicture":eventPicture, "time":time]
        
    }
    
}
