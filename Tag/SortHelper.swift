//
//  SortHelper.swift
//  Tag
//
//  Created by Gavin Robertson on 3/21/17.
//  Copyright © 2017 Tag Along. All rights reserved.
//

import Foundation



class SortHelper{
    var currentUser:User!
    //initliaze with user that is used to sort
    init(currentUser:String, users:[User]){
        for user in users{
            if (user.uid == currentUser){
                self.currentUser = user
            }
        }

    }
     func allButUserEvents(myevents:[Event]) -> [Event]{
        var events = myevents
        print(currentUser.uid)
        events = events.filter{$0.owner != currentUser.uid}
        return events
    }
    
    func onlyUserEvents( myevents:[Event])-> [Event]{
        var events = myevents
        events = events.filter{$0.owner == currentUser.uid}
        return events
    }
    
     func onlyTaggedEvents(myevents:[Event])-> [Event]{
        var events = [Event]()
        let taggedEvents = currentUser.taggedEvents
        for event in myevents{
            if taggedEvents.contains((event.itemRef?.key)!){
                events.append(event)
            }
        }
        return events
    }
    
     func allButTaggedEvents(myevents:[Event])-> [Event]{
        var events:[Event] = []
        let taggedEvents = currentUser.taggedEvents
        print(taggedEvents.count)
        for event in myevents{
            if !taggedEvents.contains((event.itemRef?.key)!){
                events.append(event)
            }
        }
        return events
    }
    
     func allButDiscardedEvents(myevents:[Event])-> [Event]{
        var events:[Event] = []
        let discardedEvents = currentUser.discardedEvents
        for event in myevents{
            if !discardedEvents.contains((event.itemRef?.key)!){
                events.append(event)
            }
        }
        return events
        
    }
    
     func onlyDiscardedEvents(myevents:[Event])-> [Event]{
        //TODO FIX
        var events = myevents
        events = events.filter{$0.owner == currentUser.uid}
        return events
    }
    
     func allEventsInRadius(radius:Int, myevents:[Event])-> [Event]{
        //TODO FIX
        return myevents
    }
     func organizeByRadius(myevents:[Event])-> [Event]{
        //TODO FIX
        return myevents
    }
    
    
    
}
