//
//  SettingsViewController.swift
//  Tag
//
//  Created by Gavin Robertson on 2/20/17.
//  Copyright © 2017 Tag Along. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class SettingsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var image:UIImage?
    var currentUserObj:User!
    var sorter:SortHelper!
    var storageRef:FIRStorageReference!
    var users = [User]()
    let storage = FIRStorage.storage()
    var dbRefUser:FIRDatabaseReference!
    let profilePicStoragePath = "Images/ProfileImage/"
    let imagePicker = UIImagePickerController()
    let currentUser = FIRAuth.auth()?.currentUser
    var startLogout = true
    
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        imagePicker.delegate = self;
        dbRefUser = FIRDatabase.database().reference().child("users")
        storageRef = storage.reference(forURL: "gs://tag-along-6c539.appspot.com")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startObservingDBCompletion()
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logoutFromSettings(_ sender: Any) {
        try! FIRAuth.auth()!.signOut()
    
    }
    @IBAction func changeProfilePic(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    func  imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage]as! UIImage
        self.performSegue(withIdentifier: "segueToCropper", sender: image)
        dismiss(animated:true, completion: nil) //5
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "segueToCropper") {
            let secondViewController = segue.destination as! ImageCropperViewController
            let image = sender as! UIImage
            secondViewController.image = image
            
        }
    }
    
    func startObservingDBCompletion(){
        self.startObservingDB(completion: {
            self.sorter = SortHelper(currentUser: (self.currentUser?.uid)!, users: self.users)
            self.currentUserObj = self.sorter.currentUser
            if (self.currentUserObj != nil){
                let imageRef = self.storageRef.child(self.profilePicStoragePath + self.currentUserObj.profilePicture)
                imageRef.data(withMaxSize: 1 * 30000 * 30000) { data, error in
                    if let error = error {
                        print(error)
                    } else {
                        let image = UIImage(data: data!)
                        self.imageView.image = image
                        
                    }
                }
            }
        })
    }
    
    func startObservingDB (completion: @escaping () -> Void) {
        dbRefUser.observe(.value, with: { (snapshot:FIRDataSnapshot) in
            var newUsers = [User]()
            for user in snapshot.children {
                let userObject = User(snapshot: user as! FIRDataSnapshot)
                newUsers.append(userObject)
            }
            self.users = newUsers
            completion()
            
        }) { (error:Error) in
            print(error.localizedDescription)
        }
        
        
    }
    
    
    
    
}
