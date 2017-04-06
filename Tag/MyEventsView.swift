//
//  MyEventsView.swift
//  Tag
//
//  Created by Gavin Robertson on 2/18/17.
//  Copyright © 2017 Tag Along. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class MyEventsView: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var dbRefEvent:FIRDatabaseReference!
    var dbRefUser:FIRDatabaseReference!
    var storageRef:FIRStorageReference!
    var events = [Event]()
    var users = [User]()
    let storage = FIRStorage.storage()
    let currentUser = FIRAuth.auth()?.currentUser
    let imagePicker = UIImagePickerController()
    let profilePicStoragePath = "Images/ProfileImage/"
    let eventPicStoragePath = "Images/EventImage/"
    var sorter:SortHelper!
    var taggedEvents = [Event]()
    var hostedEvents = [Event]()
    var allEvents = [Event]()
    @IBOutlet weak var filter: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        imagePicker.delegate = self;
        dbRefEvent = FIRDatabase.database().reference().child("events")
        dbRefUser = FIRDatabase.database().reference().child("users")
        storageRef = storage.reference(forURL: "gs://tag-along-6c539.appspot.com")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.startObservingDBCompletion()
        
    }
    
    func startObservingDB (completion: @escaping () -> Void) {
        dbRefEvent.observe(.value, with: { (snapshot:FIRDataSnapshot) in
            var newEvents = [Event]()
            
            
            for event in snapshot.children {
                let eventObject = Event(snapshot: event as! FIRDataSnapshot)
                newEvents.append(eventObject)
            }
            self.events = newEvents
            self.tableView.reloadData()
            
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
            self.tableView.reloadData()
            
        }) { (error:Error) in
            print(error.localizedDescription)
        }
    }
    
    @IBAction func mainPress(_ sender: Any) {
        self.performSegue(withIdentifier: "segueToMain", sender: self)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(filter.selectedSegmentIndex){
        case 0: return taggedEvents.count
        case 1: return hostedEvents.count
        default: return allEvents.count
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "editEventSegue") {
            let secondViewController = segue.destination as! CreateEventViewController
            let event = sender as! Event
            secondViewController.event = event
            
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let event:Event!
        switch(filter.selectedSegmentIndex){
        case 0: event = taggedEvents[indexPath.row]
        case 1: event = hostedEvents[indexPath.row]
        default: event = allEvents[indexPath.row]
        }
        if (event.owner == currentUser?.uid){
            self.performSegue(withIdentifier: "editEventSegue", sender: event)
        }else{
            //TODO bring up uneditable view
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath)
        //        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "LabelCell")
        let event:Event!
        switch(filter.selectedSegmentIndex){
        case 0: event = taggedEvents[indexPath.row]
        case 1: event = hostedEvents[indexPath.row]
        default: event = allEvents[indexPath.row]
        }
        cell.textLabel?.text = event.eventName
        cell.detailTextLabel?.text = event.eventSummary
        //todo change to event pic
        let eventPic = event.eventPicture
        let imageRef = storageRef.child(eventPicStoragePath + eventPic)
        
        imageRef.data(withMaxSize: 1 * 30000 * 30000) { data, error in
            if let error = error {
                print(error)
                cell.imageView?.image = #imageLiteral(resourceName: "noEventPic.png")
            } else {
                let image = UIImage(data: data!)
                cell.imageView?.image = image
            }
        }
        cell.layoutSubviews()
        return cell
    }
    @IBAction func newEvent(_ sender: Any) {
        self.performSegue(withIdentifier: "toNewEvent", sender:self)
    }
    @IBAction func toMain(_ sender: Any) {
        self.performSegue(withIdentifier: "toMain", sender:self)
        
    }
    @IBAction func controlAction(_ sender: Any) {
        viewDidAppear(true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        //        if editingStyle == .delete{
        //            let event = events[indexPath.row]
        //            event.itemRef?.removeValue()
        //        }
    }
    
    
    
    func startObservingDBCompletion(){
        self.startObservingDB(completion: {
            self.sorter = SortHelper(currentUser: (self.currentUser?.uid)!, users: self.users)
            self.taggedEvents = self.sorter.onlyTaggedEvents(myevents: self.events)
            self.hostedEvents = self.sorter.onlyUserEvents(myevents: self.events)
            self.allEvents = self.taggedEvents + self.hostedEvents
        })
    }
    
}
