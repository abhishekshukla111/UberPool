//
//  ViewController.swift
//  UberPool
//
//  Created by Abhishek Shukla on 2/14/19.
//  Copyright © 2019 Abhishek Shukla. All rights reserved.
//

import UIKit
import GoogleMaps

class ViewController: UIViewController {
   
    var googleMaps: GMSMapView?
    
    var locationManager = CLLocationManager()
    //var locationSelected = CLLocation.startLocation
    
    var locationStart = CLLocation()
    var locationEnd = CLLocation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Add Google API Key
        GMSServices.provideAPIKey("AIzaSyB2muDyuWw2mPxKgYqzeIMwOaLDtoxuFTs")
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startMonitoringSignificantLocationChanges()
        
        
        // Do any additional setup after loading the view, typically from a nib.
        
        //Your map initiation code
        let location = CLLocation(latitude: -33.86, longitude: 151.20)
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 15.0)
        googleMaps = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        
        //googleMaps?.camera = camera
        googleMaps?.delegate = self
        googleMaps?.isMyLocationEnabled = true
        googleMaps?.settings.myLocationButton = true
        googleMaps?.settings.compassButton = true
        googleMaps?.settings.zoomGestures = true
        
        view = googleMaps
        
        
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        marker.title = "Sydney"
        marker.snippet = "Australia"
        marker.map = googleMaps
    
    }


}

//MARK: CLLocationManagerDelegate
extension ViewController: CLLocationManagerDelegate{
    
}


extension ViewController: GMSMapViewDelegate{
    
}
