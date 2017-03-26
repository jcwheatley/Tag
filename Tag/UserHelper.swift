//
//  UserHelper.swift
//  Tag
//
//  Created by Gavin Robertson on 3/23/17.
//  Copyright © 2017 Tag Along. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

class UserHelper {
    
    static func getCurUser() -> User{
        var curUser:User?
        let currentUserFIR = FIRAuth.auth()?.currentUser
        let dbRefUser = FIRDatabase.database().reference().child("users")
        print(dbRefUser.description())
        dbRefUser.observe(.value, with: { (snapshot:FIRDataSnapshot) in
            
            for user in snapshot.children {
                let userObject = User(snapshot: user as! FIRDataSnapshot)
                print(userObject.username)
                if (userObject.uid == currentUserFIR?.uid){
                    curUser = userObject
                }
            }
            
        }) { (error:Error) in
            print(error.localizedDescription)
        }
        return curUser!
    }
}
