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
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        //        if(widthRatio > heightRatio) {
        //            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        //        } else {
        //            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        //        }
        newSize = CGSize(width: targetSize.width,  height: targetSize.width)
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
