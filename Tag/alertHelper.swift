//
//  AlertHelper.swift
//  Tag
//
//  Created by Gavin Robertson on 3/19/17.
//  Copyright © 2017 Tag Along. All rights reserved.
//

import Foundation
import UIKit

class AlertHelper {
    static func notImplemented(ui:UIViewController){
        let errorAlert = UIAlertController(title: "Sorry", message: "This feature has not yet been implemented", preferredStyle: .alert)
        errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action:UIAlertAction) in
            errorAlert.dismiss(animated: true, completion: nil)
        }))
        ui.present(errorAlert, animated: true, completion: nil)
    }
}
