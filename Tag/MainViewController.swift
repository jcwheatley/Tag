//
//  MainViewController.swift
//  Tag
//
//  Created by Gavin Robertson on 3/19/17.
//  Copyright © 2017 Tag Along. All rights reserved.
//
import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

import UIKit

class MainViewController: UIViewController {
    
    var events = [Event]()
    var eventPics = [String:UIImage]()
    var userPics = [String:UIImage]()
    var users = [User]()
    var sorter:SortHelper!
    var currentUser:User!
    var currentEvent = "-1"
    var iterator = 0;
    var pathHelper:PathHelper!
    var eventViewOnly:PackagedEvent?
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (eventViewOnly == nil){
            LoadingHelper.loading(ui: self)
            self.poster.alpha = 0
            self.poster.center = CGPoint(x: self.view.center.x - UIScreen.main.bounds.width, y: self.view.center.y)
            pathHelper = PathHelper()
            let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
            tap.numberOfTapsRequired = 2
            view.addGestureRecognizer(tap)
            self.poster.alpha = 0
            startObservingDBCompletion()
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (eventViewOnly != nil){
            eventTitle.text = eventViewOnly?.event.eventName
            eventDescription.text = eventViewOnly?.event.eventSummary
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
            let date = dateFormatter.date(from: (eventViewOnly?.event.time)!)
            dateFormatter.dateFormat = "E, MMM dd"
            let dateString = dateFormatter.string(from: date!)
            eventTime.text = dateString
            location.text = eventViewOnly?.event.location
            eventImage.image = eventViewOnly?.image
            eventHost.text = eventViewOnly?.ownerName
            userImage.image = eventViewOnly?.userImage
            self.poster.isUserInteractionEnabled = false
            self.navigationItem.rightBarButtonItem = nil
            self.navigationItem.leftBarButtonItem?=UIBarButtonItem(title: "< Back", style: .plain, target: self, action: #selector(backAction))
            self.poster.alpha = 1
        }
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventTime: UILabel!
    @IBOutlet weak var eventDescription: UITextView!
    @IBOutlet weak var eventHost: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var poster: UIView!
    @IBOutlet weak var tagStamp: UIImageView!
    @IBOutlet weak var noMoreEventsMsg: UITextView!
    
    func doubleTapped(){
        currentUser.taggedEvents.append(currentEvent)
        let userRef = self.pathHelper.dbRefUser.child(currentUser.uid)
        let userMyTaggedEvents = userRef.child("taggedEvents")
        userMyTaggedEvents.observe(.value, with: { (snapshot:FIRDataSnapshot) in
            userMyTaggedEvents.removeAllObservers()
            let count = snapshot.childrenCount
            let userNewEvent = userMyTaggedEvents.child(count.description)
            userNewEvent.setValue(self.currentEvent)
            self.startObservingDBCompletion()
            self.slideDownPoster()
        })
    }
    
    func slideDownPoster(){
        tagStamp.alpha = 1
        UIView.animate(withDuration: 1, animations: {
            self.poster.center = CGPoint(x: self.view.center.x, y: self.view.center.y+UIScreen.main.bounds.height)
            
        }, completion: {(finished:Bool) in
            self.tagStamp.alpha = 0
            self.fillView(direction: true)
            self.poster.center = CGPoint(x: self.view.center.x - UIScreen.main.bounds.width, y: self.view.center.y)
            UIView.animate(withDuration: 0.3, animations: {
                self.poster.center = CGPoint(x: self.view.center.x, y: self.view.center.y)
                self.poster.alpha = 1
            })
        })
        
        
    }
    //creates arrays of events and users
    func startObservingDB (completion: @escaping () -> Void) {
        pathHelper.dbRefEvents.observe(.value, with: { (snapshot:FIRDataSnapshot) in
            var newEvents = [Event]()
            
            
            //this goes through firebase db and adds all events into newEvents then self.events
            for event in snapshot.children {
                let eventObject = Event(snapshot: event as! FIRDataSnapshot)
                newEvents.append(eventObject)
            }
            self.events = newEvents
            //self.tableView.reloadData()
            
        }) { (error:Error) in
            print(error.localizedDescription)
            
        }
        pathHelper.dbRefUser.observe(.value, with: { (snapshot:FIRDataSnapshot) in
            var newUsers = [User]()
            
            //todo: seems like this is not actually creating users
            for user in snapshot.children {
                let userObject = User(snapshot: user as! FIRDataSnapshot)
                newUsers.append(userObject)
            }
            self.users = newUsers
            completion()
            //self.tableView.reloadData()
            
        }) { (error:Error) in
            print(error.localizedDescription)
        }
        //more filtering
        
    }
    
    func fillView(direction:Bool){
        if events.count == 0{
            //TODO notify that there are no events
            
            //self.performSegue(withIdentifier: "noMoreEventsSegue", sender: self)
            
            self.poster.alpha = 0
            self.noMoreEventsMsg.alpha = 1
            LoadingHelper.doneLoading(ui: self)
        }
        else{
            if (direction){
                iterator -= 1
                if (iterator == -1){
                    iterator = events.count - 1
                }
            }else{
                iterator += 1
                if (iterator == events.count){
                    iterator = 0
                }
            }
            let event = events[iterator]
            if (event.itemRef?.key != currentEvent){
                eventTitle.text = event.eventName
                for user in users{
                    if (user.uid == event.owner){
                        
                        eventHost.text = "Hosted by: " + user.username
                        self.userImage.image = userPics[user.uid]
                        self.eventImage.image = eventPics[(event.itemRef?.key)!]
                    }
                }
                
                //self.userImage.layer.cornerRadius = 10.0
                self.userImage.layer.borderWidth = 1
                self.userImage.layer.masksToBounds = false
                self.userImage.layer.borderColor = UIColor.white.cgColor
                self.userImage.layer.cornerRadius = userImage.frame.height/2
                self.userImage.layer.masksToBounds = true
                
                self.view.bringSubview(toFront: eventTitle)
                self.view.bringSubview(toFront: location)
                self.view.bringSubview(toFront: eventTime)
                //self.view.bringSubview(toFront: scrollView)
                
                location.text = event.location
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                let date = dateFormatter.date(from: (event.time))
                dateFormatter.dateFormat = "E, MMM dd\nh:mm a"
                let dateString = dateFormatter.string(from: date!)
                
                eventTime.text = dateString
                
                
                eventDescription.text = event.eventSummary
                currentEvent = (event.itemRef?.key)!
            }else if(events.count == 1){
                //only one left
                //AlertHelper.notImplemented(ui: self)
                return
            }
            else{
                fillView(direction: direction)
            }
            LoadingHelper.doneLoading(ui: self)
        }
    }
    
    @IBAction func panPoster(_ sender: UIPanGestureRecognizer) {
        let poster = sender.view!
        
        //var newPoster = UIView(frame: )
        
        
        let point = sender.translation(in: view)
        
        poster.center = CGPoint(x: view.center.x + point.x, y: view.center.y)
        
        
        //when finger comes off screen
        if sender.state == UIGestureRecognizerState.ended {
            
            //when the poster is let go to either tag along or trash
            if poster.center.x < 75 {
                
                //move off to the left side of screen
                UIView.animate(withDuration: 0.3, animations: {
                    poster.center = CGPoint(x: poster.center.x - UIScreen.main.bounds.width, y: poster.center.y)
                    //poster.alpha = 0
                }, completion: {(finished:Bool) in
                    
                    self.resetPoster(direction: false)
                })
                
                return
            }
            else if poster.center.x > (view.frame.width - 75) {
                //move off to the right side
                
                UIView.animate(withDuration: 0.3, animations: {
                    poster.center = CGPoint(x: poster.center.x + UIScreen.main.bounds.width, y: poster.center.y)
                    //poster.alpha = 0
                }, completion: {(finished:Bool) in
                    
                    self.resetPoster(direction: true)
                })
                
                return
            }
            
            //If the swipe wasn't drastic enough, reset the poster to middle
            UIView.animate(withDuration: 0.2, animations: {
                poster.center = self.view.center
            })
            
        }
        
    }
    
    
    //left = false, right = true
    func resetPoster(direction: Bool) {
        //swiped right, move poster in from left
        if(direction){
            fillView(direction: false)
            self.poster.center = CGPoint(x: self.view.center.x - UIScreen.main.bounds.width, y: self.view.center.y)
            
            UIView.animate(withDuration: 0.3, animations: {
                self.poster.center = CGPoint(x: self.view.center.x, y: self.view.center.y)
                self.poster.alpha = 1
            })
            
        }
            //swiped left, move poster in from right
        else{
            fillView(direction: true)
            self.poster.center = CGPoint(x: self.view.center.x + UIScreen.main.bounds.width, y: self.view.center.y)
            
            UIView.animate(withDuration: 0.3, animations: {
                self.poster.center = CGPoint(x: self.view.center.x, y: self.view.center.y)
                self.poster.alpha = 1
            })
        }
        
    }
    
    
    @IBAction func discardEvent(_ sender: Any) {
        print ("discard event called")
        currentUser.discardedEvents.append(currentEvent)
        let userRef = self.pathHelper.dbRefUser.child(currentUser.uid)
        let userMyDiscardedEvents = userRef.child("discardedEvents")
        userMyDiscardedEvents.observe(.value, with: { (snapshot:FIRDataSnapshot) in
            userMyDiscardedEvents.removeAllObservers()
            let count = snapshot.childrenCount
            let userNewEvent = userMyDiscardedEvents.child(count.description)
            userNewEvent.setValue(self.currentEvent)
            
        })
        startObservingDBCompletion()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func toManage(_ sender: Any) {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers
        for aViewController in viewControllers {
            if aViewController is MyEventsView {
                self.navigationController!.popToViewController(aViewController, animated: true)
            }
        }
        self.performSegue(withIdentifier: "toManage", sender: self)
    }
    @IBAction func logout(_ sender: Any) {
        try! FIRAuth.auth()!.signOut()
        self.performSegue(withIdentifier: "logoutSegue", sender: self)
    }
    
    
    
    func startObservingDBCompletion(){
        self.startObservingDB(completion: {
            self.sorter = SortHelper(currentUser: (self.pathHelper.currentUserFIR?.uid)!, users: self.users)
            self.currentUser = self.sorter.currentUser
            self.events = self.sorter.removeFaultyEvents(myevents: self.events)
            self.events = self.sorter.allButUserEvents(myevents: self.events)
            self.events = self.sorter.allButDiscardedEvents(myevents: self.events)
            self.events = self.sorter.allButTaggedEvents(myevents: self.events)
            if (self.events.isEmpty){
                
                let when = DispatchTime.now() + 1
                DispatchQueue.main.asyncAfter(deadline: when) {
                    LoadingHelper.doneLoading(ui: self)
                    self.poster.alpha = 0
                    self.noMoreEventsMsg.alpha = 1
                }
                
            }else{
                self.organizePics()
            }
        })
    }
    
    func organizePics(){
        for user in users{
            let profilePic = user.profilePicture
            let imageRef = pathHelper.storageRef.child(pathHelper.profilePicStoragePath + profilePic)
            imageRef.data(withMaxSize: 1 * 30000 * 30000) { data, error in
                if let error = error {
                    print(error)
                    self.userPics[user.uid] = #imageLiteral(resourceName: "NoPic.gif")
                } else {
                    let image = UIImage(data: data!)
                    self.userPics[user.uid] = image
                }
            }
        }
        let profilePic = currentUser.profilePicture
        let imageRef = pathHelper.storageRef.child(pathHelper.profilePicStoragePath + profilePic)
        imageRef.data(withMaxSize: 1 * 30000 * 30000) { data, error in
            if let error = error {
                print(error)
                PictureManager.sharedInstance.myProfilePic = #imageLiteral(resourceName: "NoPic.gif")
            } else {
                let image = UIImage(data: data!)
                PictureManager.sharedInstance.myProfilePic = image!
            }
        }
        for event in events{
            let eventPic = event.eventPicture
            let imageRef = self.pathHelper.storageRef.child(self.pathHelper.eventPicStoragePath + eventPic)
            imageRef.data(withMaxSize: 1 * 30000 * 30000) { data, error in
                if error != nil{
                    print("error")
                    self.eventPics[event.owner] = #imageLiteral(resourceName: "noEventPic.png")
                }else{
                    let image = UIImage(data: data!)
                    self.eventPics[(event.itemRef?.key)!] = image!
                }
                if (self.eventPics.count == self.events.count){
                    self.fillView(direction: true)
                    self.poster.alpha = 1
                    UIView.animate(withDuration: 0.3, animations: {
                        self.poster.center = CGPoint(x: self.view.center.x, y: self.view.center.y)
                    })
                    
                }
            }
            
        }
        
        
    }
}


