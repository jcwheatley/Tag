//
//  ImageCropperViewController.swift
//  ImageCropper
//
//  Created by Aatish Rajkarnikar on 10/4/16.
//  Copyright © 2016 iOSHub. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseAuth
import FirebaseDatabase

class ImageCropperViewController: UIViewController, UIScrollViewDelegate, UINavigationControllerDelegate {
    var image:UIImage?
    var userImg:Bool = true;
    var eventID:String?
    var pathHelper:PathHelper!
    let currentUser = FIRAuth.auth()?.currentUser
    let profilePicStoragePath = "Images/ProfileImage/"
    var storageRef:FIRStorageReference!
    let storage = FIRStorage.storage()
    var dbRefUser:FIRDatabaseReference!
    
    @IBOutlet var scrollView: UIScrollView!{
        didSet{
            scrollView.delegate = self
            scrollView.minimumZoomScale = 1.0
            scrollView.maximumZoomScale = 3.0
        }
    }
    
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var cropAreaView: CropAreaView!
    
    var cropArea:CGRect{
        get{
            let factor = imageView.image!.size.width/view.frame.width
            let scale = 1/scrollView.zoomScale
            let imageFrame = imageView.imageFrame()
            let x = (scrollView.contentOffset.x + cropAreaView.frame.origin.x - imageFrame.origin.x) * scale * factor
            let y = (scrollView.contentOffset.y + cropAreaView.frame.origin.y - imageFrame.origin.y) * scale * factor
            let width = cropAreaView.frame.size.width * scale * factor
            let height = cropAreaView.frame.size.height * scale * factor
            return CGRect(x: x, y: y, width: width, height: height)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pathHelper = PathHelper()
        dbRefUser = FIRDatabase.database().reference().child("users")
        storageRef = storage.reference(forURL: "gs://tag-along-6c539.appspot.com")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (image != nil){
            imageView.image = image
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    
    
    @IBAction func crop(_ sender: UIButton) {
        self.view.isUserInteractionEnabled = false
        LoadingHelper.loading(ui: self)
        UIView.animate(withDuration: 0.2, animations: {
            self.cropAreaView.alpha = 0.8
        })
        let croppedCGImage = imageView.image?.cgImage?.cropping(to: cropArea)
        var croppedImage = UIImage(cgImage: croppedCGImage!)
        
        if (userImg){
            croppedImage = ImageHelper.resizeImage(image: croppedImage, targetSize: CGSize(width: 100, height: 100))
            let data = UIImagePNGRepresentation(croppedImage)
            let picName = (currentUser?.uid)! + ".png"
            let picRef = storageRef.child(profilePicStoragePath+picName)
            _ = picRef.put(data!, metadata: nil){ metadata, error in
                if let error = error{
                    print(error)}
                else{
                    let currentUser = FIRAuth.auth()?.currentUser
                    var userRef = self.dbRefUser.child((currentUser!.uid))
                    userRef = userRef.child("profilePicture")
                    userRef.setValue(picName)
                    LoadingHelper.doneLoading(ui: self)
                    let viewController = self.navigationController?.viewControllers
                    let count = viewController?.count
                    if let setVC = viewController?[count! - 2] as? SettingsViewController {
                        setVC.imageView.image = croppedImage
                    }
                    _ = self.navigationController?.popViewController(animated: true)
                }
                
            }
        }else{
            croppedImage = ImageHelper.resizeImage(image: croppedImage, targetSize: CGSize(width: 600, height: 600))
            let data = UIImagePNGRepresentation(croppedImage)
            let picName = (eventID)! + ".png"
            let picRef = storageRef.child(pathHelper.eventPicStoragePath+picName)
                _ = picRef.put(data!, metadata: nil){ metadata, error in
                if let error = error{
                    print(error)}
                else{
                    var eventRef = self.pathHelper.dbRefEvents.child(self.eventID!)
                    eventRef = eventRef.child("eventPicture")
                    eventRef.setValue(picName)
                    let viewController = self.navigationController?.viewControllers
                    let count = viewController?.count
                    if let setVC = viewController?[count! - 2] as? CreateEventViewController {
                        setVC.image = croppedImage
                    }
                    LoadingHelper.doneLoading(ui: self)
                    _ = self.navigationController?.popViewController(animated: true)
                    self.scrollView.zoomScale = 1
                }
                
            }
        }
    }
}
extension UIImageView{
    func imageFrame()->CGRect{
        let imageViewSize = self.frame.size
        guard let imageSize = self.image?.size else{return CGRect.zero}
        let imageRatio = imageSize.width / imageSize.height
        let imageViewRatio = imageViewSize.width / imageViewSize.height
        
        if imageRatio < imageViewRatio {
            let scaleFactor = imageViewSize.height / imageSize.height
            let width = imageSize.width * scaleFactor
            let topLeftX = (imageViewSize.width - width) * 0.5
            return CGRect(x: topLeftX, y: 0, width: width, height: imageViewSize.height)
        }else{
            let scalFactor = imageViewSize.width / imageSize.width
            let height = imageSize.height * scalFactor
            let topLeftY = (imageViewSize.height - height) * 0.5
            return CGRect(x: 0, y: topLeftY, width: imageViewSize.width, height: height)
        }
    }
}

class CropAreaView: UIView {
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return false
    }
    
}



