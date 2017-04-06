//
//  NoEventsViewController.swift
//  Tag
//
//  Created by James Wheatley on 4/4/17.
//  Copyright © 2017 Tag Along. All rights reserved.
//

import UIKit

class NoEventsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }

}
