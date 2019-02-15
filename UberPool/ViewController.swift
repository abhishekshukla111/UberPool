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
    @IBOutlet weak var getDirectionButton: UIButton!
    
    @IBOutlet weak var startTextField1: UITextField!
    @IBOutlet weak var destinationTextField1: UITextField!
    @IBOutlet weak var startTextField2: UITextField!
    @IBOutlet weak var destinationTextField2: UITextField!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addRightBarButton()
    }

    @IBAction func quickTestAction (_ sender: Any){
        //This is for demo
        startTextField1.text = "Delhi"
        destinationTextField1.text = "Lucknow"
        startTextField2.text = "Patna"
        destinationTextField2.text = "Mumbai"
        
        getDirectionButton.isEnabled = true
    }
    
    @IBAction func getDirectionAction (_ sender: Any){
       
        //Some Cleanup before draw
        resignAllTextfields()
        googleMaps.clear()
        
        var locationArray: [String] = []
        locationArray.append(startTextField1.text!)
        locationArray.append(destinationTextField1.text!)
        locationArray.append(startTextField2.text!)
        locationArray.append(destinationTextField2.text!)
        
        let dispatchGroup = DispatchGroup()
        
        var clLocationArray: [CLLocation] = []
        for location in locationArray{
            dispatchGroup.enter()
            print("Start Location: \(location)")
            DispatchQueue.main.async {
                self.getCoordinates(from: location) { (location) in
                    clLocationArray.append(location)
                    print("Got Location: \(location.coordinate.latitude)")
                    dispatchGroup.leave()
                }
            }
        }
        
        _ = dispatchGroup.wait(timeout: DispatchTime(uptimeNanoseconds: 60 * 1000000000))
        
        dispatchGroup.notify(queue: .main) {
            let startlocation = clLocationArray[0]
            let endLocation = clLocationArray[1]
            let wayPoints = Array(clLocationArray[2...])
            self.drawPath(startLocation: startlocation, endLocation: endLocation, wayPoints: wayPoints)
        }
    }
    
    @IBAction func clearAction (_ sender: Any){
        startTextField1.text = ""
        destinationTextField1.text = ""
        startTextField2.text = ""
        destinationTextField2.text = ""
        googleMaps.clear()
        getDirectionButton.isEnabled = false
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
            
            let dateAndTime = self.getDataAndTime()
            
            let data = ["Date": dateAndTime, "StartLocation":"\(startLocation.coordinate.latitude), \(startLocation.coordinate.longitude)","EndLocation":"\(startLocation.coordinate.latitude), \(startLocation.coordinate.longitude)"]
            
            ArchiveUtility.shared.updateData(data: data)
            
        }) { (error) in
            print("\(error)")
        }
    }
    
    func drawRoute(from routes: [JSON]){
        //route using Polyline
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
    
    
    private func addRightBarButton(){
        let navItem = UINavigationItem(title: "Uber Pool")
        
        let historyBarButton = UIBarButtonItem(title: "History", style: .plain, target: self, action: #selector(historyButtonAction(_:)))
        navItem.rightBarButtonItem = historyBarButton
        
        self.navigationController?.navigationBar.setItems([navItem], animated: false)
    }
    
    @objc func historyButtonAction( _ sender: Any){
        let historyViewController = HistoryViewController()
        self.navigationController?.pushViewController(historyViewController, animated: true)
    }
    
    private func resignAllTextfields(){
        startTextField1.resignFirstResponder()
        startTextField2.resignFirstResponder()
        destinationTextField1.resignFirstResponder()
        destinationTextField2.resignFirstResponder()
    }
    
    private func getDataAndTime() -> String{
        var dateAndTime = ""
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        
        if let year =  components.year, let month = components.month, let day = components.day, let hour = components.hour, let minute = components.minute {
            dateAndTime = "\(String(describing: day))/\(String(describing: month))/\(String(describing: year)) \(hour):\(String(describing: minute))"
        }
    
        return dateAndTime
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
        
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        return false
    }
    
}

// MARK: Text Field Delegates
extension ViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {

    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        validateAllTextFieldHasData()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    
        return true
    }
    
    
    func validateAllTextFieldHasData(){
        if (startTextField1.text?.isEmpty)! ||
            (startTextField2.text?.isEmpty)! ||
            (destinationTextField1.text?.isEmpty)! ||
            (destinationTextField2.text?.isEmpty)!{
            getDirectionButton.isEnabled = false
        }else{
            getDirectionButton.isEnabled = true
        }
    }
    
}
