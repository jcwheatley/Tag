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
    
    var events = [Event]()
    var users = [User]()
    let storage = FIRStorage.storage()
    let imagePicker = UIImagePickerController()
    var sorter:SortHelper!
    var taggedEvents = [Event]()
    var hostedEvents = [Event]()
    var allEvents = [Event]()
    var eventPics = [String:UIImage]()
    
    var pathHelper:PathHelper!
    var userPics = [String:UIImage]()
    var taggedCount = 0
    var hostedCount = 0
    @IBOutlet weak var filter: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pathHelper = PathHelper()
        self.navigationController?.isNavigationBarHidden = false
        imagePicker.delegate = self;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.startObservingDBCompletion()
        
    }
    
    func startObservingDB (completion: @escaping () -> Void) {
        pathHelper.dbRefEvents.observe(.value, with: { (snapshot:FIRDataSnapshot) in
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
        pathHelper.dbRefUser.observe(.value, with: { (snapshot:FIRDataSnapshot) in
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
        switch(self.filter.selectedSegmentIndex){
        case 0: return self.taggedEvents.count
        case 1: return self.hostedEvents.count
        default: return self.allEvents.count
        }
        //        return eventPics.count
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
        if (event.owner == pathHelper.currentUserFIR?.uid){
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier :"eventEditor") as! CreateEventViewController
            vc.event = event
            vc.viewDidLoad()
            vc.inputPicture.image = eventPics[(event.itemRef?.key)!]
            self.navigationController?.pushViewController(vc, animated:true)
        }else{
            let newView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "home") as! MainViewController
            var user:User!
            for u in users{
                if (u.uid == event.owner){
                    user = u
                }
            }
            let packagedEvent = PackagedEvent(event: event, ownerName: user.username, image: eventPics[(event.itemRef?.key)!]!, userImage: userPics[user.uid]!)
            newView.eventViewOnly = packagedEvent
            newView.viewDidLoad()
            newView.viewDidAppear(false)
            newView.poster.alpha = 0
            self.navigationController?.pushViewController(newView, animated: true)
            //TODO bring up uneditable view
            
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath)
        let event:Event!
        switch(filter.selectedSegmentIndex){
        case 0: event = taggedEvents[indexPath.row]
        case 1: event = hostedEvents[indexPath.row]
        default: event = allEvents[indexPath.row]
        }
        cell.textLabel?.text = event.eventName
        cell.detailTextLabel?.text = event.eventSummary
        
        cell.imageView?.image = eventPics[(event.itemRef?.key)!]
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
            self.sorter = SortHelper(currentUser: (self.pathHelper.currentUserFIR!.uid), users: self.users)
            self.taggedEvents = self.sorter.onlyTaggedEvents(myevents: self.events)
            self.hostedEvents = self.sorter.onlyUserEvents(myevents: self.events)
            self.allEvents = self.taggedEvents + self.hostedEvents
            self.organizePics(events: self.allEvents)
        })
    }
    
    func organizePics(events:[Event]){
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
                    self.tableView.reloadData()
            }
            
        }
        
    }
    
}
