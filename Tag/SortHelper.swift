//
//  SortHelper.swift
//  Tag
//
//  Created by Gavin Robertson on 3/21/17.
//  Copyright © 2017 Tag Along. All rights reserved.
//

import Foundation



class SortHelper{
    var currentUser:User?
    static func allButUserEvents(userId:String , myevents:[Event]) -> [Event]{
        var events = myevents
        events = events.filter{$0.owner != userId}
        return events
    }
    
    static func onlyUserEvents(userId:String, myevents:[Event])-> [Event]{
        var events = myevents
        events = events.filter{$0.owner == userId}
        return events
    }
    
    static func onlyTaggedEvents(user:User, myevents:[Event])-> [Event]{
        var events:[Event]?
        let taggedEvents = user.taggedEvents
        for event in myevents{
            if taggedEvents.contains((event.itemRef?.key)!){
                events?.append(event)
            }
        }
        return events!
    }
    
    static func allButTaggedEvents(user:User, myevents:[Event])-> [Event]{
        var events:[Event]?
        let taggedEvents = user.taggedEvents
        for event in myevents{
            if !taggedEvents.contains((event.itemRef?.key)!){
                events?.append(event)
            }
        }
        return events!
    }
    
    static func allButDiscardedEvents(user:User, myevents:[Event])-> [Event]{
        var events = myevents
        let discardedEvents = user.discardedEvents
        for event in myevents{
            if !discardedEvents.contains((event.itemRef?.key)!){
                events.append(event)
            }
        }
        return events
    }
    
    static func onlyDiscardedEvents(userId:String, myevents:[Event])-> [Event]{
        //TODO FIX
        var events = myevents
        events = events.filter{$0.owner == userId}
        return events
    }
    
    static func allEventsInRadius(radius:Int, myevents:[Event])-> [Event]{
        //TODO FIX
        return myevents
    }
    static func organizeByRadius(myevents:[Event])-> [Event]{
        //TODO FIX
        return myevents
    }
    
    static func getCurrentUser(currentUser:String, users:[User]) -> User{
        for user in users{
            if (user.uid == currentUser){
                return user
            }
        }
        return User(uid: "-1", email: "-1", username: "-1", profilePicture: "-1")
    }
    
    
    
}
