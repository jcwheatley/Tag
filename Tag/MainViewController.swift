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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LoadingHelper.loading(ui: self)
        dbRefEvents = FIRDatabase.database().reference().child("events")
        dbRefUser = FIRDatabase.database().reference().child("users")
        storageRef = storage.reference(forURL: "gs://tag-along-6c539.appspot.com")
        startObservingDB()
        
        // Do any additional setup after loading the view.
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
            if (event.itemRef?.description != currentEvent){
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
                
                
                eventLocation.text = event.location
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                let date = dateFormatter.date(from: (event.time))
                dateFormatter.dateFormat = "dd/MM/yyyy\nHH:mm"
                let dateString = dateFormatter.string(from: date!)
                
                
                eventTime.text = dateString
                eventDescription.text = event.eventSummary
                currentEvent = (event.itemRef?.description())!
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
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func toManage(_ sender: Any) {
        self.performSegue(withIdentifier: "toManage", sender: self)
    }
    @IBAction func tagAlong(_ sender: Any) {
        AlertHelper.notImplemented(ui: self)
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

