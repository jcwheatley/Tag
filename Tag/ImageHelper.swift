//
//  ImageHelper.swift
//  Tag
//
//  Created by Gavin Robertson on 2/21/17.
//  Copyright © 2017 Tag Along. All rights reserved.
//

import UIKit
import Foundation

class ImageHelper{
    static func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        
        var newSize: CGSize

        newSize = CGSize(width: targetSize.width,  height: targetSize.width)

        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    
}
