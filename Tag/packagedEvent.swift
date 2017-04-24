//
//  File.swift
//  Tag
//
//  Created by Gavin Robertson on 4/23/17.
//  Copyright © 2017 Tag Along. All rights reserved.
//

import Foundation
import UIKit

struct PackagedEvent{
    let event:Event
    let ownerName:String
    let image:UIImage
    let userImage:UIImage
    init (event:Event, ownerName:String, image:UIImage, userImage:UIImage) {
        self.event = event
        self.ownerName = ownerName
        self.image = image
        self.userImage = userImage
    }
}
