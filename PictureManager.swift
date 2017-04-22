//
//  PictureManager.swift
//  Tag
//
//  Created by Gavin Robertson on 4/20/17.
//  Copyright © 2017 Tag Along. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class PictureManager {
    static let sharedInstance = PictureManager()
    var eventPics = [String:UIImage]()
    var userPics = [String:UIImage]()
    var myProfilePic = UIImage()
}
