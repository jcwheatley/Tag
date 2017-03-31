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
    var needsLogin = true
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated:true);
        dbRefUser = FIRDatabase.database().reference().child("users")
    // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        FIRAuth.auth()?.addStateDidChangeListener({ (auth:FIRAuth, user:FIRUser?) in
            if let user = user{
                if (self.needsLogin){
                    print("Welcome " + user.email!)
                    self.needsLogin = false
//                    try! FIRAuth.auth()!.signOut()
                    self.performSegue(withIdentifier: "segueToMain", sender: self)
                }
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
                }else if let user = user{
                    let userRef = self.dbRefUser.child((user.uid))
                    let user = User(uid: (user.uid), email: (user.email)!, username: (self.displayName)!, profilePicture: ("NoPic.gif"))
                    userRef.setValue(user.toAnyObject())
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
    }
    
}
