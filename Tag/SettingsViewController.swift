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
    var storageRef:FIRStorageReference!
    let storage = FIRStorage.storage()
    var dbRefUser:FIRDatabaseReference!
    let profilePicStoragePath = "Images/ProfileImage/"
    let imagePicker = UIImagePickerController()
    let currentUser = FIRAuth.auth()?.currentUser
    var startLogout = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        imagePicker.delegate = self;
        dbRefUser = FIRDatabase.database().reference().child("users")
        storageRef = storage.reference(forURL: "gs://tag-along-6c539.appspot.com")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logoutFromSettings(_ sender: Any) {
        if (startLogout){
            try! FIRAuth.auth()!.signOut()
            self.performSegue(withIdentifier: "logoutFromSettingsSegue", sender: self)
            startLogout = false
        }
        
    }
    @IBAction func changeProfilePic(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    func  imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var image = info[UIImagePickerControllerOriginalImage]as! UIImage
        image = ImageHelper.resizeImage(image: image, targetSize: CGSize(width: 100, height: 100))
        let data = UIImagePNGRepresentation(image)
        let picName = (currentUser?.uid)! + ".png"
        let picRef = storageRef.child(profilePicStoragePath+picName)
        _ = picRef.put(data!, metadata: nil){ metadata, error in
            if let error = error{
                print(error)}
            else{
                let currentUser = FIRAuth.auth()?.currentUser
                var userRef = self.dbRefUser.child((currentUser!.uid))
                userRef = userRef.child("profilePicture")
                userRef.setValue(picName)
            }
        }
        dismiss(animated:true, completion: nil) //5
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
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
