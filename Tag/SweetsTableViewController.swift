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
    
    
    var dbRefSweet:FIRDatabaseReference!
    var dbRefUser:FIRDatabaseReference!
    var storageRef:FIRStorageReference!
    var sweets = [Sweet]()
    var users = [User]()
    let storage = FIRStorage.storage()
    let currentUser = FIRAuth.auth()?.currentUser
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self;
        dbRefSweet = FIRDatabase.database().reference().child("sweet-items")
        dbRefUser = FIRDatabase.database().reference().child("users")
        storageRef = storage.reference(forURL: "gs://tag-along-6c539.appspot.com")
        startObservingDB()
    }
    @IBAction func ProfileChange(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        present(imagePicker, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.startObservingDB()
    }
    @IBAction func loginAndSignup(_ sender: Any) {
        try! FIRAuth.auth()!.signOut()
        self.performSegue(withIdentifier: "loginSegue", sender: self)
    }
    
    func startObservingDB () {
        dbRefSweet.observe(.value, with: { (snapshot:FIRDataSnapshot) in
            var newSweets = [Sweet]()
            var newUsers = [User]()
            
            //todo: seems like this is not actually creating users
            for user in snapshot.children {
                let userObject = User(snapshot: user as! FIRDataSnapshot)
                newUsers.append(userObject)
            }
            
            for sweet in snapshot.children {
                let sweetObject = Sweet(snapshot: sweet as! FIRDataSnapshot)
                newSweets.append(sweetObject)
            }
            self.sweets = newSweets
            self.users = newUsers
            self.tableView.reloadData()
            
        }) { (error:Error) in
            print(error.localizedDescription)
        }
    }
    @IBAction func addSweet(_ sender: Any) {
        let sweetAlert = UIAlertController(title: "New Sweet", message: "Eneter your Sweet", preferredStyle: .alert)
        sweetAlert.addTextField { (textField:UITextField) in
            textField.placeholder = "Your sweet"
        }
        sweetAlert.addAction(UIAlertAction(title: "Send", style: .default, handler: { (action:UIAlertAction) in
            if let sweetContent = sweetAlert.textFields?.first?.text{
                let sweetRef = self.dbRefSweet.child(sweetContent.lowercased())
                let autoID = sweetRef.childByAutoId().key
                let sweet = Sweet(content: sweetContent, addedByUser: (self.currentUser?.displayName)!, key: autoID)
                sweetRef.setValue(sweet.toAnyObject())
            }
        }))
        self.present(sweetAlert, animated: true, completion: nil)
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
        print("sweets count : " + sweets.count.description)
        return sweets.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath)
        //        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "LabelCell")
        
        let sweet = sweets[indexPath.row]
        cell.textLabel?.text = sweet.content
        cell.detailTextLabel?.text = sweet.addedByUser
        var profilePic = "Images/ProfileImage/NoPic.gif"
        for user in users{
            print(users[0].username + " " + sweet.addedByUser)
        if user.username == sweet.addedByUser{
            profilePic = "Images/ProfileImage/NoPic.gif" + user.profilePicture
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
        if editingStyle == .delete{
            let sweet = sweets[indexPath.row]
            if (sweet.addedByUser == currentUser?.displayName){
                sweet.itemRef?.removeValue()
            }
            else{
                let sorryAlert = UIAlertController(title: "Sorry", message: "You cannot delete someone else's message", preferredStyle: .alert)
                sorryAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action:UIAlertAction) in
                    sorryAlert.dismiss(animated: true, completion: nil)
                }))
                self.present(sorryAlert, animated: true, completion: nil)
            }
        }
        
    }
    
    
    func  imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let imageUrl          = info[UIImagePickerControllerReferenceURL] as! URL
        let imageName         = imageUrl.lastPathComponent
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let photoURL          = NSURL(fileURLWithPath: documentDirectory)
        let localPath         = photoURL.appendingPathComponent(imageName)
        let image             = info[UIImagePickerControllerOriginalImage]as! UIImage
        let data              = UIImagePNGRepresentation(image)
        
        
        print(localPath!.path)
        
        // Create a reference to the file you want to upload
        print(currentUser?.displayName)
        let picRef = storageRef.child("Images/ProfileImage/"+(currentUser?.displayName)! + ".png")
        let uploadTask = picRef.put(data!, metadata: nil){ metadata, error in
            if let error = error{
                print(error)}
            else{
                let changeRequest = self.currentUser?.profileChangeRequest()
                changeRequest?.photoURL = URL(string:"Images/ProfileImage/" + (self.currentUser?.displayName)! +  ".png")
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
