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
import GooglePlaces

//this just gets rid of keyboard when tapped outside of textfield

class CreateEventViewController: UIViewController, UITextFieldDelegate {
    var dbRefEvent:FIRDatabaseReference!
    var dbRefUser:FIRDatabaseReference!
    var locationID:String = "-1"
    var event:Event?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (event != nil){
            inputEventName.text = event?.eventName
            inputEventSummary.text = event?.eventSummary
            inputLocation.text = event?.location
            inputPrivate.setOn((event?.privateEvent)!, animated: false)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
            let date = dateFormatter.date(from: (event?.time)!)
            inputTime.setDate(date!, animated: false)
            createButton.setTitle("Update",for: .normal)
           
            
        }
        self.hideKeyboard()
        toggleMeetingLocation()
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
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var hasMeetingLocation: UISwitch!
    @IBOutlet weak var inputMeetingLocation: UITextField!
    
    @IBAction func manageEvents(_ sender: Any) {
        
        
        self.performSegue(withIdentifier: "returnToMyEvents", sender: self)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        inputEventName.resignFirstResponder()
        inputEventSummary.resignFirstResponder()
        inputLocation.resignFirstResponder()
        return false
    }
    
    func toggleMeetingLocation(){
        if (!hasMeetingLocation.isOn){
            inputMeetingLocation.isHidden = true
        }
        else{
            inputMeetingLocation.isHidden = false
        }
    }
    
    @IBAction func actionSlide(_ sender: Any) {
        toggleMeetingLocation()
    }
    // Present the Autocomplete view controller when the button is pressed.
    @IBAction func autocompleteClicked(_ sender: UITextField) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    @IBAction func createEvent(_ sender: Any) {
        if (inputEventSummary.text == "" || inputEventName.text == "" || inputLocation.text == "" || inputTime.description == ""){
            let errorAlert = UIAlertController(title: "Error", message: "Please fill in required information.", preferredStyle: .alert)
            errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action:UIAlertAction) in
                errorAlert.dismiss(animated: true, completion: nil)
            }))
            self.present(errorAlert, animated: true, completion: nil)
        }else{
            let eventRef:FIRDatabaseReference
            if (self.event == nil){
                eventRef = self.dbRefEvent.childByAutoId()
            }
            else{
                eventRef = (self.event?.itemRef)!
            }
            
            let eventName = inputEventName.text
            let eventSummary = inputEventSummary.text
            let eventLocation = inputLocation.text
            let eventTime = inputTime.date.description
            let isPrivate = inputPrivate.isOn
            let eventOwner = FIRAuth.auth()?.currentUser?.uid
            let eventPicture = inputPicture.image
            let event = Event(eventName: eventName!, owner: eventOwner!, eventSummary: eventSummary!, location: eventLocation!, locationID: locationID, meetingLocation: "temp", meetingLocationID:"temp", privateEvent: isPrivate, eventPicture: "temp", time: eventTime)
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

extension CreateEventViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        self.locationID = place.placeID
        
        
        
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress)")
        print("Place attributions: \(place.attributions)")
        locationID = place.placeID
        inputLocation.text = place.formattedAddress
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    
}
