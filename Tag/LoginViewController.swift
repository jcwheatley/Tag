//
//  LoginViewController.swift
//  ChatApp
//
//  Created by Gavin Robertson on 2/7/17.
//  Copyright © 2017 Gavin Robertson. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage



class LoginViewController: UIViewController {
    
    var dbRefUser:FIRDatabaseReference!
    var displayName:String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated:true);
        dbRefUser = FIRDatabase.database().reference().child("users")
    // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        var needsLogin = true
        FIRAuth.auth()?.addStateDidChangeListener({ (auth:FIRAuth, user:FIRUser?) in
            if let user = user{
                if (needsLogin){
                    print("Welcome " + user.email!)
                    self.performSegue(withIdentifier: "segue", sender: self)
                    needsLogin = false
                    
                    let changeRequest = user.profileChangeRequest()
                    changeRequest.photoURL = URL(string:"Images/ProfileImage/NoPic.gif")
                    if (self.displayName != nil){
                        changeRequest.displayName = self.displayName
                        changeRequest.commitChanges { (error:Error?) in
                            if let error = error {
                                print("your error: " + error.localizedDescription)
                            } else {
                                let currentUser = FIRAuth.auth()?.currentUser
                                let userRef = self.dbRefUser.child((currentUser!.uid))
                                let user = User(uid: (currentUser?.uid)!, email: (currentUser?.email)!, username: (currentUser?.displayName)!, profilePicture: (currentUser?.photoURL?.absoluteString)!)
                                userRef.setValue(user.toAnyObject())
                            }
                        }
                    }
                }
            }else{
                print("you need to login first")
            }
            
            
        })
    }
    
    @IBAction func Login(_ sender: Any) {
        let userAlert = UIAlertController(title: "Login/Sign Up", message: "Enter email and password", preferredStyle: .alert)
        userAlert.addTextField { (textfield:UITextField) in
            textfield.placeholder = "email"
        }
        
        userAlert.addTextField { (textfield:UITextField) in
            textfield.isSecureTextEntry = true
            textfield.placeholder = "password"
        }
        
        userAlert.addAction(UIAlertAction(title: "Sign in", style: .default, handler: { (action:UIAlertAction) in
            let emailTextField = userAlert.textFields!.first!.text!
            let passwordTextField = userAlert.textFields!.last!.text!
            
            FIRAuth.auth()?.signIn(withEmail: emailTextField, password: passwordTextField, completion: { (user, error) in
                if error != nil{
                    let errorAlert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action:UIAlertAction) in
                        errorAlert.dismiss(animated: true, completion: nil)
                    }))
                    print(error?.localizedDescription as Any)
                    self.present(errorAlert, animated: true, completion: nil)
                }
                
            })
        }))
        
        userAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action:UIAlertAction) in
            userAlert.dismiss(animated: true, completion: nil)
        }))
        
        
        self.present(userAlert, animated: true, completion: nil)
    }
    @IBAction func signUP(_ sender: Any) {
        
        let userAlert = UIAlertController(title: "Sign Up", message: "Enter email, username, and password", preferredStyle: .alert)
        userAlert.addTextField { (textfield:UITextField) in
            textfield.placeholder = "email"
        }
        
        userAlert.addTextField { (textfield:UITextField) in
            textfield.placeholder = "username"
        }
        
        userAlert.addTextField { (textfield:UITextField) in
            textfield.isSecureTextEntry = true
            textfield.placeholder = "password"
        }
        userAlert.addAction(UIAlertAction(title: "Sign up", style: .default, handler: { (action:UIAlertAction) in
            let emailTextField = userAlert.textFields![0].text!
            let passwordTextField = userAlert.textFields![2].text!
            self.displayName = userAlert.textFields![1].text!
            
            FIRAuth.auth()?.createUser(withEmail: emailTextField, password: passwordTextField, completion: { (user, error) in
                if error != nil{
                    let errorAlert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action:UIAlertAction) in
                        errorAlert.dismiss(animated: true, completion: nil)
                    }))
                    print(error?.localizedDescription as Any)
                    self.present(errorAlert, animated: true, completion: nil)
                }
            })
        }))
        
        userAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action:UIAlertAction) in
            userAlert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(userAlert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
