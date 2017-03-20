//
//  loadingHelper.swift
//  Tag
//
//  Created by Gavin Robertson on 3/19/17.
//  Copyright © 2017 Tag Along. All rights reserved.
//

import Foundation
import UIKit

class LoadingHelper: UIViewController {
    static func loading(ui:UIViewController){

        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        
        alert.view.tintColor = UIColor.black
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50)) as UIActivityIndicatorView
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        ui.present(alert, animated: true, completion: nil)
    }
    static func doneLoading(ui:UIViewController){
        ui.dismiss(animated: false, completion: nil)
    }
}


