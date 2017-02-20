//
//  MyEventsView.swift
//  Tag
//
//  Created by Gavin Robertson on 2/18/17.
//  Copyright © 2017 Tag Along. All rights reserved.
//

import UIKit
import FirebaseDatabase

class MyEventsView: UITableViewController {
    
    var dbRefEvent:FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dbRefEvent = FIRDatabase.database().reference().child("events")
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
//    @IBAction func addEvent(_ sender: Any) {
//        let eventAlert = UIAlertController(title: "New Event", message: "Create Your Event", preferredStyle: .alert)
//        
//    
//        eventAlert.addTextField { (textField:UITextField) in
//            textField.placeholder = "Event Name"
//        }
//        eventAlert.addTextField { (textField:UITextField) in
//            textField.placeholder = "Event Details"
//        }
//        eventAlert.addTextField { (textField:UITextField) in
//            textField.placeholder = "Location"
//        }
//        eventAlert.addTextField { (textField:UITextField) in
//            textField.placeholder = "Add Picture"
//        }
//        eventAlert.addAction(UIAlertAction(title: "Create Public Event", style: .default, handler: { (action:UIAlertAction) in
//            let eventName = eventAlert.textFields?[0]
//            let eventDetails = eventAlert.textFields?[1]
//            let location = eventAlert.textFields?[2]
//        
//        }))
//        eventAlert.addAction(UIAlertAction(title: "Create Private Event", style: .default, handler: { (action:UIAlertAction) in
//            
//        }))
//        eventAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action:UIAlertAction) in
//            
//        }))
//        self.present(eventAlert, animated: true, completion: nil)
//    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
    
    /*
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
     
     // Configure the cell...
     
     return cell
     }
     */
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
