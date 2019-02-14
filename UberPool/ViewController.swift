//
//  ViewController.swift
//  UberPool
//
//  Created by Abhishek Shukla on 2/14/19.
//  Copyright © 2019 Abhishek Shukla. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire
import SwiftyJSON

class ViewController: UIViewController {
   
    var googleMaps: GMSMapView?
    
    var locationManager = CLLocationManager()
    //var locationSelected = CLLocation.startLocation
    
    var locationStart = CLLocation()
    var locationEnd = CLLocation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Add Google API Key
        GMSServices.provideAPIKey("AIzaSyCeZMQyak_ixe9tVcsedmXEjfvOLwofAiA")
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startMonitoringSignificantLocationChanges()
        
        
        // Do any additional setup after loading the view, typically from a nib.
        
        //Your map initiation code
        let startlocation = CLLocation(latitude: 28.617500, longitude: 77.208228)
        //let endLocation = CLLocation(latitude: 28.615276, longitude: 77.199444) //Rashtpathi bhavan
        //let endLocation = CLLocation(latitude: 28.569090, longitude: 77.122422) //Airport
        let endLocation = CLLocation(latitude: 28.643796, longitude: 77.218396) //NDLS
        
        let camera = GMSCameraPosition.camera(withLatitude: startlocation.coordinate.latitude, longitude: startlocation.coordinate.longitude, zoom: 15.0)
        googleMaps = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        
        //googleMaps?.camera = camera
        googleMaps?.delegate = self
        googleMaps?.isMyLocationEnabled = true
        googleMaps?.settings.myLocationButton = true
        googleMaps?.settings.compassButton = true
        googleMaps?.settings.zoomGestures = true
        
        view = googleMaps
        
        
        createMarker(titleMarker: "Indian Parliament", latitude: startlocation.coordinate.latitude, longitude: startlocation.coordinate.longitude)
        createMarker(titleMarker: "Rashtrapati Bhavan", latitude: endLocation.coordinate.latitude, longitude: endLocation.coordinate.longitude)
        
        drawPath(startLocation: startlocation, endLocation: endLocation)
        getDistance(startLocation: startlocation, endLocation: endLocation)
        
        self.googleMaps?.animate(to: camera)


    }
    
    // MARK: function for create a marker pin on map
    func createMarker(titleMarker: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(latitude, longitude)
        marker.title = titleMarker
        marker.map = googleMaps
    }
    
    //MARK: - this is function for create direction path, from start location to desination location
    
    func drawPath(startLocation: CLLocation, endLocation: CLLocation)
    {
        let origin = "\(startLocation.coordinate.latitude),\(startLocation.coordinate.longitude)"
        let destination = "\(endLocation.coordinate.latitude),\(endLocation.coordinate.longitude)"
        
        
        //let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=AIzaSyCeZMQyak_ixe9tVcsedmXEjfvOLwofAiA"
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=Parliament+Of+India,New+Delhi&destination=NDLS+Railway+Station,+New+Delhi&mode=driving&key=AIzaSyCeZMQyak_ixe9tVcsedmXEjfvOLwofAiA&waypoints=optimize:true%7C28.613841,77.132252%7C28.613195,77.229488%7C28.641980,77.249560"
        //let url = "https://maps.googleapis.com/maps/api/directions/json?origin=Disneyland&destination=Universal+Studios+Hollywood&key=AIzaSyCeZMQyak_ixe9tVcsedmXEjfvOLwofAiA"
        //let url = "https://maps.googleapis.com/maps/api/directions/json?origin=New Delhi Railway Station&destination=New Delhi Airport&mode=driving&key=AIzaSyCeZMQyak_ixe9tVcsedmXEjfvOLwofAiA"
        //let url = "http://maps.googleapis.com/maps/api/directions/json?origin=Adelaide,SA&destination=Adelaide,SA&waypoints=optimize:true|Barossa+Valley,SA|Clare,SA|Connawarra,SA|McLaren+Vale,SA&sensor=false&key=AIzaSyCeZMQyak_ixe9tVcsedmXEjfvOLwofAiA"
        Alamofire.request(url).responseJSON { response in
            
            print(response.request as Any)  // original URL request
            print(response.response as Any) // HTTP URL response
            print(response.data as Any)     // server data
            print(response.result as Any)   // result of response serialization
            
            var routes: [JSON] = []
            //let bounds: [String : JSON]?
            do {
                let json = try JSON(data: response.data!)
                routes = json["routes"].arrayValue
                //bounds = json["bounds"].dictionary
            } catch let error {
                print("Error: \(error)")
            }
            
            // print route using Polyline
            for route in routes
            {
                let routeOverviewPolyline = route["overview_polyline"].dictionary
                let points = routeOverviewPolyline?["points"]?.stringValue
                let path = GMSPath.init(fromEncodedPath: points!)
                let polyline = GMSPolyline.init(path: path)
                polyline.strokeWidth = 4
                polyline.strokeColor = UIColor.blue
                polyline.map = self.googleMaps
            }
            
            let bounds = GMSCoordinateBounds(coordinate: startLocation.coordinate, coordinate: endLocation.coordinate)
            //bounds.includingCoordinate(<#T##coordinate: CLLocationCoordinate2D##CLLocationCoordinate2D#>)
            self.googleMaps?.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 100))
            
        }
    }
    
    func getDistance(startLocation: CLLocation, endLocation: CLLocation)
    {
        let origin = "\(startLocation.coordinate.latitude),\(startLocation.coordinate.longitude)"
        let destination = "\(endLocation.coordinate.latitude),\(endLocation.coordinate.longitude)"
        let rajGhat = "28.641980,77.249560"
        let indiaGate = "28.613195,77.229488"
        let armyHospital = "28.613841,77.132252"
        //let url = "https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=40.6655101,-73.89188969999998&destinations=40.6905615%2C-73.9976592%7C40.6905615%2C-73.9976592%7C40.6905615%2C-73.9976592%7C40.6905615%2C-73.9976592%7C40.6905615%2C-73.9976592%7C40.6905615%2C-73.9976592%7C40.659569%2C-73.933783%7C40.729029%2C-73.851524%7C40.6860072%2C-73.6334271%7C40.598566%2C-73.7527626%7C40.659569%2C-73.933783%7C40.729029%2C-73.851524%7C40.6860072%2C-73.6334271%7C40.598566%2C-73.7527626&key=AIzaSyCeZMQyak_ixe9tVcsedmXEjfvOLwofAiA"
        let url = "https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=\(origin)&destinations=\(destination)%7C\(rajGhat)&key=AIzaSyCeZMQyak_ixe9tVcsedmXEjfvOLwofAiA"

    
    
         Alamofire.request(url).responseJSON { response in
            
            //print(response)
            do {
                let json = try JSON(data: response.data!)
                print(json)
                //routes = json["routes"].arrayValue
                //bounds = json["bounds"].dictionary
            } catch let error {
                print("Error: \(error)")
            }
        }
    
    }


}

//MARK: CLLocationManagerDelegate
extension ViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error to get location : \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last
        
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 17.0)
        
        let locationTujuan = CLLocation(latitude: 37.784023631590777, longitude: -122.40486681461333)
        
        createMarker(titleMarker: "Lokasi Tujuan", latitude: locationTujuan.coordinate.latitude, longitude: locationTujuan.coordinate.longitude)
        
        createMarker(titleMarker: "Lokasi Aku", latitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!)
        
        drawPath(startLocation: location!, endLocation: locationTujuan)
        
        self.googleMaps?.animate(to: camera)
        self.locationManager.stopUpdatingLocation()
        
    }
}


extension ViewController: GMSMapViewDelegate{
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        googleMaps?.isMyLocationEnabled = true
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        googleMaps?.isMyLocationEnabled = true
        
        if (gesture) {
            mapView.selectedMarker = nil
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        googleMaps?.isMyLocationEnabled = true
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("COORDINATE \(coordinate)") // when you tapped coordinate
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        googleMaps?.isMyLocationEnabled = true
        googleMaps?.selectedMarker = nil
        return false
    }
    
}
