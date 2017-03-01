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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self;
        dbRefEvent = FIRDatabase.database().reference().child("events")
        dbRefUser = FIRDatabase.database().reference().child("users")
        storageRef = storage.reference(forURL: "gs://tag-along-6c539.appspot.com")
        startObservingDB()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.startObservingDB()
        
    }
    
    func startObservingDB () {
        dbRefEvent.observe(.value, with: { (snapshot:FIRDataSnapshot) in
            var newEvents = [Event]()
            
            
            for event in snapshot.children {
                let eventObject = Event(snapshot: event as! FIRDataSnapshot)
                if (eventObject.owner == self.currentUser?.uid){
                    newEvents.append(eventObject)
                }
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
        return events.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath)
        //        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "LabelCell")
        
        let event = events[indexPath.row]
        cell.textLabel?.text = event.eventName
        cell.detailTextLabel?.text = event.eventSummary
        //todo change to event pic
        let profilePic = currentUser?.photoURL?.absoluteString
        if (true){
            //  let imageRef = storageRef.child((currentUser?.photoURL?.absoluteString)!)
            let imageRef = storageRef.child(profilePic!)
            //imageRef.data(withMaxSize: 1 * 1024 * 1024) { data, error in
            imageRef.data(withMaxSize: 1 * 30000 * 30000) { data, error in
                if let error = error {
                    print(error)
                } else {
                    let image = UIImage(data: data!)
                    cell.imageView?.image = image
                }
            }
        }
        cell.layoutSubviews()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let event = events[indexPath.row]
            event.itemRef?.removeValue()
        }
    }
    
}
