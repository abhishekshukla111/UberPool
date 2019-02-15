//
//  ViewController.swift
//  UberPool
//
//  Created by Abhishek Shukla on 2/14/19.
//  Copyright © 2019 Abhishek Shukla. All rights reserved.
//

import UIKit
import GoogleMaps
import SwiftyJSON

class ViewController: UIViewController {
   
    @IBOutlet weak var googleMaps: UBGMSMapView!
    @IBOutlet weak var inputContainerView: UIView!
    
    @IBOutlet weak var startTextField1: UITextField!
    @IBOutlet weak var destinationTextField1: UITextField!
    @IBOutlet weak var startTextField2: UITextField!
    @IBOutlet weak var destinationTextField2: UITextField!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //let endLocation = CLLocation(latitude: 28.615276, longitude: 77.199444) //Rashtpathi bhavan
        //let endLocation = CLLocation(latitude: 28.569090, longitude: 77.122422) //Airport
       
        //        let camera = GMSCameraPosition.camera(withLatitude: startlocation.coordinate.latitude, longitude: startlocation.coordinate.longitude, zoom: 15.0)
        //
        //        googleMaps?.camera = camera
        //        googleMaps?.delegate = self
    }
    
    @IBAction func getDirectionAction (_ sender: Any){
        print("getDrirectionAction")
        let getCoordinatesDispatchGroup = DispatchGroup()
        
//        let startlocation = CLLocation(latitude: 28.617500, longitude: 77.208228)
//        let endLocation = CLLocation(latitude: 28.643796, longitude: 77.218396) //NDLS
//
//        let wayPoints = [CLLocation(latitude: 28.613841, longitude: 77.132252),
//                         CLLocation(latitude: 28.613195, longitude: 77.229488),
//                         CLLocation(latitude: 28.615276, longitude: 77.199444),
//                         CLLocation(latitude: 28.569090, longitude: 77.122422)]
        
        
        
        //getDistance(startLocation: startlocation, endLocation: endLocation, wayPoints: nil)
        
        let locationArray = ["Parliament Of India,New Delhi", "NDLS Railway Station, New Delhi", "India Gate, New Delhi", "Indira Gandhi International Airport,New Delhi"]
        var clLocationArray: [CLLocation] = []
        for location in locationArray{
            getCoordinatesDispatchGroup.enter()
            getCoordinates(from: location) { (location) in
                clLocationArray.append(location)
                getCoordinatesDispatchGroup.leave()
            }
        }
        
        _ = getCoordinatesDispatchGroup.wait(timeout: DispatchTime(uptimeNanoseconds: 60 * 1000000000))
        
        getCoordinatesDispatchGroup.notify(queue: .main) {
            print("All executed")
            print(clLocationArray)
            
            let startlocation = clLocationArray[0]
            let endLocation = clLocationArray[1]
            let wayPoints = Array(clLocationArray[2...])
            self.drawPath(startLocation: startlocation, endLocation: endLocation, wayPoints: wayPoints)
        }
    }
    
    //Function to get the CLLocation from an Address in string
    func getCoordinates(from address:String, completion: @escaping (_ location: CLLocation)->()){
        UBGoogleAPIHandler().getCoordinates(from: address, completion: { (location) in
            if let location = location{
                completion(location)
            }
        }) { (error) in
            print("Get Coordinates failed with error: \(error)")
        }
    }
    
    //Function to get the distance between points
    func getDistance(startLocation: CLLocation, endLocation: CLLocation, wayPoints: [CLLocation]?){
        UBGoogleAPIHandler().getDistance(startLocation: startLocation, endLocation: endLocation, wayPoints: nil
            , completion: { (distances) in
                print(distances)
        }) { (error) in
            print("Get Distance failed with error: \(error)")
        }
    }

    
    // MARK: function for create a marker pin on map
    func createMarker(at location: CLLocation) {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        marker.map = googleMaps
    }
    
    //MARK: - this is function for create direction path, from start location to desination location
    
    func drawPath(startLocation: CLLocation, endLocation: CLLocation, wayPoints: [CLLocation])
    {
        UBGoogleAPIHandler().getRoute(for: startLocation, endLocation: endLocation, wayPoints:wayPoints, completion: { [unowned self] (routes) in
            self.drawRoute(from: routes)
            self.addBounds(startLocation: startLocation, endLocation: endLocation, wayPoints: wayPoints)
            self.addMarkers(startLocation: startLocation, endLocation: endLocation, wayPoints: wayPoints)
            
        }) { (error) in
            print("\(error)")
        }
    }
    
    func drawRoute(from routes: [JSON]){
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
    }
    
    func addMarkers(startLocation: CLLocation, endLocation: CLLocation, wayPoints: [CLLocation]){
        createMarker(at: startLocation)
        createMarker(at: endLocation)
        for wayPoint in wayPoints{
            createMarker(at: wayPoint)
        }
    }
    
    func addBounds(startLocation: CLLocation, endLocation: CLLocation, wayPoints: [CLLocation]){
        var bounds = GMSCoordinateBounds()
        bounds = bounds.includingCoordinate(startLocation.coordinate)
        bounds = bounds.includingCoordinate(endLocation.coordinate)
       
        for wayPoint in wayPoints{
            bounds = bounds.includingCoordinate(wayPoint.coordinate)
        }
        self.googleMaps?.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 40))
    }
}

//MARK: CLLocationManagerDelegate
extension ViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error to get location : \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
}


extension ViewController: GMSMapViewDelegate{
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("COORDINATE \(coordinate)") // when you tapped coordinate
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        return false
    }
    
}
