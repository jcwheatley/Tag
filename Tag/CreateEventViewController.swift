//
//  CreateEventViewController.swift
//  Tag
//
//  Created by Gavin Robertson on 2/20/17.
//  Copyright © 2017 Tag Along. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

//this just gets rid of keyboard when tapped outside of textfield

class CreateEventViewController: UIViewController, UITextFieldDelegate {
    
    
    var dbRefEvent:FIRDatabaseReference!
    var dbRefUser:FIRDatabaseReference!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
        dbRefEvent = FIRDatabase.database().reference().child("events")
        dbRefUser = FIRDatabase.database().reference().child("users")
        // Do any additional setup after loading the view.
    }
    @IBOutlet weak var inputEventName: UITextField!
    @IBOutlet weak var inputEventSummary: UITextField!
    @IBOutlet weak var inputLocation: UITextField!
    @IBOutlet weak var inputPrivate: UISwitch!
    @IBOutlet weak var inputPicture: UIImageView!
    @IBOutlet weak var inputTime: UIDatePicker!
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        inputEventName.resignFirstResponder()
        inputEventSummary.resignFirstResponder()
        return false
    }
    
    @IBAction func createEvent(_ sender: Any) {
        if (inputEventSummary.text == "" || inputEventName.text == "" || inputLocation.text == "" || inputTime.description == ""){
            let errorAlert = UIAlertController(title: "Error", message: "Please fill in required information.", preferredStyle: .alert)
            errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action:UIAlertAction) in
                errorAlert.dismiss(animated: true, completion: nil)
            }))
            self.present(errorAlert, animated: true, completion: nil)
        }else{
            
            let eventRef = self.dbRefEvent.childByAutoId()
            let eventName = inputEventName.text
            let eventSummary = inputEventSummary.text
            let eventLocation = inputLocation.text
            let eventTime = inputTime.date.description
            let isPrivate = inputPrivate.isOn
            let eventOwner = FIRAuth.auth()?.currentUser?.uid
            let eventPicture = inputPicture.image
            let event = Event(eventName: eventName!, owner: eventOwner!, eventSummary: eventSummary!, location: eventLocation!, privateEvent: isPrivate, eventPicture: "temp", time: eventTime)
            eventRef.setValue(event.toAnyObject())
            let userRef = self.dbRefUser.child(eventOwner!)
            let userMyEvents = userRef.child("myEvents")
            userMyEvents.observe(.value, with: { (snapshot:FIRDataSnapshot) in
                userMyEvents.removeAllObservers()
                let count = snapshot.childrenCount
                let userNewEvent = userMyEvents.child(count.description)
                userNewEvent.setValue(eventRef.key)
                
            })
            self.performSegue(withIdentifier: "returnToMyEvents", sender: self)
        }
    }
    @IBAction func changePicture(_ sender: Any) {
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
