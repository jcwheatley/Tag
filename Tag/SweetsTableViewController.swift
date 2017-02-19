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
    let profilePicStoragePath = "Images/ProfileImage/"
    
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
            
            
            for sweet in snapshot.children {
                let sweetObject = Sweet(snapshot: sweet as! FIRDataSnapshot)
                newSweets.append(sweetObject)
            }
            self.sweets = newSweets
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
        var profilePic = profilePicStoragePath + "NoPic.gif"
        for user in users{
            print(sweets.count)
            if user.username == sweet.addedByUser{
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
        var image = info[UIImagePickerControllerOriginalImage]as! UIImage
        image = self.resizeImage(image: image, targetSize: CGSize(width: 100, height: 100))
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
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
//        if(widthRatio > heightRatio) {
//            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
//        } else {
//            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
//        }
        newSize = CGSize(width: targetSize.width,  height: targetSize.width)
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
}
