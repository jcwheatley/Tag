//
//  SwetsTableViewController.swift
//  ChatApp
//
//  Created by Gavin Robertson on 1/24/17.
//  Copyright © 2017 Gavin Robertson. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage


class SweetsTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    var dbRefEvents:FIRDatabaseReference!
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
        dbRefEvents = FIRDatabase.database().reference().child("events")
        dbRefUser = FIRDatabase.database().reference().child("users")
        storageRef = storage.reference(forURL: "gs://tag-along-6c539.appspot.com")
        startObservingDB()
    }
    
    @IBAction func ProfileChange(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        present(imagePicker, animated: true, completion: nil)
        self.startObservingDB()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.startObservingDB()
    }
    @IBAction func loginAndSignup(_ sender: Any) {
        try! FIRAuth.auth()!.signOut()
        self.performSegue(withIdentifier: "loginSegue", sender: self)
    }
    @IBAction func Logout(_ sender: Any) {
        try! FIRAuth.auth()!.signOut()
        self.performSegue(withIdentifier: "loginSegue", sender: self)
    }
    
    func startObservingDB () {
        dbRefEvents.observe(.value, with: { (snapshot:FIRDataSnapshot) in
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
        return events.count
        
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath)
        let event = events[indexPath.row]
        cell.textLabel?.text = event.eventName
        
        dbRefUser.child(event.owner).observe(.value, with: { (snapshot:FIRDataSnapshot) in
            let user = snapshot
            let userObject = User(snapshot: user)
            let name = userObject.username
            cell.textLabel?.text = event.eventName
            cell.detailTextLabel?.text = name
        })
        var profilePic = profilePicStoragePath + "NoPic.gif"
        for user in users{
            if user.uid == event.owner{
                profilePic = user.profilePicture
            }
            
        }
        if (true){
            //  let imageRef = storageRef.child((currentUser?.photoURL?.absoluteString)!)
            let imageRef = storageRef.child(profilePic)
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
        
    }
    
    func  imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var image = info[UIImagePickerControllerOriginalImage]as! UIImage
        image = ImageHelper.resizeImage(image: image, targetSize: CGSize(width: 100, height: 100))
        let data = UIImagePNGRepresentation(image)
        let picName = (currentUser?.displayName)! + ".png"
        let picRef = storageRef.child(profilePicStoragePath+picName)
        _ = picRef.put(data!, metadata: nil){ metadata, error in
            if let error = error{
                print(error)}
            else{
                let changeRequest = self.currentUser?.profileChangeRequest()
                changeRequest?.photoURL = URL(string: self.profilePicStoragePath + (self.currentUser?.displayName)! +  ".png")
                changeRequest?.commitChanges { (error:Error?) in
                    if let error = error {
                        print("your error: " + error.localizedDescription)
                    } else {
                        let currentUser = FIRAuth.auth()?.currentUser
                        let userRef = self.dbRefUser.child((currentUser!.displayName)!)
                        let user = User(uid: (currentUser?.uid)!, email: (currentUser?.email)!, username: (currentUser?.displayName)!, profilePicture: (currentUser?.photoURL?.absoluteString)!)
                        userRef.setValue(user.toAnyObject())
                    }
                }
            }
        }
        dismiss(animated:true, completion: nil) //5
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
}
