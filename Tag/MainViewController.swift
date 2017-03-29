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
    
    var dbRefEvents:FIRDatabaseReference!
    var dbRefUser:FIRDatabaseReference!
    var storageRef:FIRStorageReference!
    var events = [Event]()
    var users = [User]()
    var sorter:SortHelper!
    var currentUser:User!
    let storage = FIRStorage.storage()
    let currentUserFIR = FIRAuth.auth()?.currentUser
    let profilePicStoragePath = "Images/ProfileImage/"
    var currentEvent = "-1"
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LoadingHelper.loading(ui: self)
        dbRefEvents = FIRDatabase.database().reference().child("events")
        dbRefUser = FIRDatabase.database().reference().child("users")
        storageRef = storage.reference(forURL: "gs://tag-along-6c539.appspot.com")
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        eventImage.isUserInteractionEnabled = true
        eventImage.addGestureRecognizer(tapGestureRecognizer)
        
        
        //let settingsView = SwipeDownSettingsViewController(nibName: "SwipeDownSettingsViewController", bundle: nil)
        
        //var frame1 = settingsView.view.frame
        //frame1.origin.x = self.view.frame.size.width
        //settingsView.view.frame = frame1
        
        //self.addChildViewController(settingsView)
        //self.scrollView.addSubview(settingsView.view)
        //settingsView.didMove(toParentViewController: self)
        
        //self.scrollView.contentSize = CGSize(width: self.view.frame.width * 2, height: self.view.frame.size.height)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startObservingDBCompletion()
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventTime: UILabel!
    @IBOutlet weak var eventDescription: UITextView!
    @IBOutlet weak var eventHost: UILabel!
    @IBOutlet weak var eventLocation: UILabel!
    @IBOutlet weak var eventLocationBtn: UIButton!
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var userImage: UIImageView!
    
    
    
    
    //creates arrays of events and users
    func startObservingDB (completion: @escaping () -> Void) {
        dbRefEvents.observe(.value, with: { (snapshot:FIRDataSnapshot) in
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
        dbRefUser.observe(.value, with: { (snapshot:FIRDataSnapshot) in
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
    
    
    func fillView(){
        if events.count == 0{
            LoadingHelper.doneLoading(ui: self)
            AlertHelper.notImplemented(ui: self)
        }
        else{
            let i = Int(arc4random_uniform(UInt32(events.count)))
            //make sure that we arent filling up the view with the same event
            let event = events[i]
            if (event.itemRef?.key != currentEvent){
                eventTitle.text = event.eventName
                
                for user in users{
                    if (user.uid == event.owner){
                        
                        eventHost.text = "Hosted by: " + user.username
                        
                        let profilePic = user.profilePicture
                        let imageRef = storageRef.child(profilePic)
                        print(imageRef)
                        imageRef.data(withMaxSize: 1 * 30000 * 30000) { data, error in
                            if let error = error {
                                print(error)
                            } else {
                                let image = UIImage(data: data!)
                                self.userImage.image = image
                            }
                        }
                        
                    }
                }
                
                self.view.bringSubview(toFront: eventTitle)
                self.view.bringSubview(toFront: eventLocation)
                self.view.bringSubview(toFront: eventTime)
                //self.view.bringSubview(toFront: scrollView)
                
                eventLocation.text = event.location
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                let date = dateFormatter.date(from: (event.time))
                dateFormatter.dateFormat = "dd/MM/yyyy\nHH:mm"
                let dateString = dateFormatter.string(from: date!)
                
                
                eventTime.text = dateString
                eventDescription.text = event.eventSummary
                currentEvent = (event.itemRef?.key)!
            }else if(events.count == 1){
                //only one left
                AlertHelper.notImplemented(ui: self)
                return
            }
            else{
                fillView()
            }
            LoadingHelper.doneLoading(ui: self)
        }
    }
    
    
    
    @IBAction func refresh(_ sender: Any) {
        self.fillView()
    }
    @IBAction func discardEvent(_ sender: Any) {
        currentUser.discardedEvents.append(currentEvent)
        let userRef = self.dbRefUser.child(currentUser.uid)
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
        self.performSegue(withIdentifier: "toManage", sender: self)
    }
    @IBAction func logout(_ sender: Any) {
        try! FIRAuth.auth()!.signOut()
        self.performSegue(withIdentifier: "logoutSegue", sender: self)
    }
    
    @IBAction func toMap(_ sender: Any) {
        self.performSegue(withIdentifier: "toMapSegue", sender: self)
    }
    
    
    
    @IBAction func tagAlong(_ sender: Any) {
        
        currentUser.taggedEvents.append(currentEvent)
        let userRef = self.dbRefUser.child(currentUser.uid)
        let userMyTaggedEvents = userRef.child("taggedEvents")
        userMyTaggedEvents.observe(.value, with: { (snapshot:FIRDataSnapshot) in
            userMyTaggedEvents.removeAllObservers()
            let count = snapshot.childrenCount
            let userNewEvent = userMyTaggedEvents.child(count.description)
            userNewEvent.setValue(self.currentEvent)
            
        })
        startObservingDBCompletion()
    }
    
    func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        
        print("it worked!!")
    }
    
    func startObservingDBCompletion(){
        self.startObservingDB(completion: {
            self.sorter = SortHelper(currentUser: (self.currentUserFIR?.uid)!, users: self.users)
            self.currentUser = self.sorter.currentUser
            self.events = self.sorter.allButUserEvents(myevents: self.events)
            self.events = self.sorter.allButDiscardedEvents(myevents: self.events)
            self.events = self.sorter.allButTaggedEvents(myevents: self.events)
            self.fillView()
        })
    }
}

