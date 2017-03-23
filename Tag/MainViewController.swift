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
    let storage = FIRStorage.storage()
    let currentUser = FIRAuth.auth()?.currentUser
    let profilePicStoragePath = "Images/ProfileImage/"
    var currentEvent = "-1"
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LoadingHelper.loading(ui: self)
        dbRefEvents = FIRDatabase.database().reference().child("events")
        dbRefUser = FIRDatabase.database().reference().child("users")
        storageRef = storage.reference(forURL: "gs://tag-along-6c539.appspot.com")
        startObservingDB()
        
        // Do any additional setup after loading the view.
        
        let settingsView = SwipeDownSettingsViewController(nibName: "SwipeDownSettingsViewController", bundle: nil)
        
        var frame1 = settingsView.view.frame
        frame1.origin.x = self.view.frame.size.width
        settingsView.view.frame = frame1
        
        self.addChildViewController(settingsView)
        self.scrollView.addSubview(settingsView.view)
        settingsView.didMove(toParentViewController: self)
        
        self.scrollView.contentSize = CGSize(width: self.view.frame.width * 2, height: self.view.frame.size.height)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.startObservingDB()
    }
    
    
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventTime: UILabel!
    @IBOutlet weak var eventDescription: UITextView!
    @IBOutlet weak var eventHost: UILabel!
    @IBOutlet weak var eventLocation: UILabel!
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var userImage: UIImageView!
    
    
    
    
    //creates arrays of events and users
    func startObservingDB () {
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
            self.fillView()
            //self.tableView.reloadData()
            
        }) { (error:Error) in
            print(error.localizedDescription)
        }
        
        
        
    }
    
    func fillView(){
        
        if events.count > 0{
            let i = Int(arc4random_uniform(UInt32(events.count)))
            //make sure that we arent filling up the view with the same event
            let event = events[i]
            if (event.itemRef?.key != currentEvent && event.owner != currentUser?.uid){
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
                self.view.bringSubview(toFront: scrollView)
                
                eventLocation.text = event.location
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                let date = dateFormatter.date(from: (event.time))
                dateFormatter.dateFormat = "dd/MM/yyyy\nHH:mm"
                let dateString = dateFormatter.string(from: date!)
                
                
                eventTime.text = dateString
                eventDescription.text = event.eventSummary
                currentEvent = (event.itemRef?.key)!
            }
            else if events.count == 1{
                AlertHelper.noMoreEvents(ui: self)
            }
                
            else{
                fillView()
            }
        }
        
        LoadingHelper.doneLoading(ui: self)
    }
    
    
    
    @IBAction func refresh(_ sender: Any) {
        self.fillView()
    }
    @IBAction func discardEvent(_ sender: Any) {
        var curUser = SortHelper.getCurrentUser(currentUser: (currentUser?.uid)!, users: users)
        curUser.discardedEvents.append(currentEvent)
        let userRef = self.dbRefUser.child(curUser.uid)
        let userMyDiscardedEvents = userRef.child("discardedEvents")
        userMyDiscardedEvents.observe(.value, with: { (snapshot:FIRDataSnapshot) in
            userMyDiscardedEvents.removeAllObservers()
            let count = snapshot.childrenCount
            let userNewEvent = userMyDiscardedEvents.child(count.description)
            userNewEvent.setValue(self.currentEvent)
            
        })
        
        self.fillView()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func toManage(_ sender: Any) {
        self.performSegue(withIdentifier: "toManage", sender: self)
    }
    @IBAction func tagAlong(_ sender: Any) {
        var curUser = SortHelper.getCurrentUser(currentUser: (currentUser?.uid)!, users: users)
        curUser.taggedEvents.append(currentEvent)
        let userRef = self.dbRefUser.child(curUser.uid)
        let userMyTaggedEvents = userRef.child("taggedEvents")
        userMyTaggedEvents.observe(.value, with: { (snapshot:FIRDataSnapshot) in
            userMyTaggedEvents.removeAllObservers()
            let count = snapshot.childrenCount
            let userNewEvent = userMyTaggedEvents.child(count.description)
            userNewEvent.setValue(self.currentEvent)
            
        })
        self.fillView()
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

