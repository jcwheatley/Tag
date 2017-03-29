//
//  MapViewController.swift
//  Tag
//
//  Created by Gavin Robertson on 3/29/17.
//  Copyright © 2017 Tag Along. All rights reserved.
//

import UIKit
import GoogleMaps

class MapViewController: UIViewController {

    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6)
//        let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
//        
//        mapView.isMyLocationEnabled = true
//        
//        self.view = mapView
//        
//        
//        let marker = GMSMarker()
//        
//        marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
//        marker.title = "Sydney"
//        marker.snippet = "Australia"
//        marker.map = mapView
        
        
    }
    
    override func loadView() {
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        view = mapView
        
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
        marker.title = "Sydney"
        marker.snippet = "Australia"
        marker.map = mapView
    }
    
    
    

}
