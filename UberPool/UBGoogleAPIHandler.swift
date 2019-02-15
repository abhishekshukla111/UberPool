//
//  UBGoogleAPIHandler.swift
//  UberPool
//
//  Created by Abhishek Shukla on 2/15/19.
//  Copyright © 2019 Abhishek Shukla. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import Alamofire
import SwiftyJSON

typealias RoutesCompletionBlock = (_ routes: [JSON]) -> ()
typealias CordinatesCompletionBlock = (_ location: CLLocation?) -> ()
typealias DistanceComplitionBlock = (_ distances: [Int])->()
typealias NetworkFailureBlock = (_ errorString:String) -> Void

class UBGoogleAPIHandler{
    
    //MARK: Google Directions API
    func getRoute(for startLocation: CLLocation, endLocation: CLLocation, completion: @escaping RoutesCompletionBlock, failure: @escaping NetworkFailureBlock){
        getRoute(for: startLocation, endLocation: endLocation, wayPoints: nil, completion: completion, failure: failure)
    }
    
    func getRoute(for startLocation: CLLocation, endLocation: CLLocation, wayPoints: [CLLocation]?, completion: @escaping RoutesCompletionBlock, failure: @escaping NetworkFailureBlock){
       
        let origin = "\(startLocation.coordinate.latitude),\(startLocation.coordinate.longitude)"
        let destination = "\(endLocation.coordinate.latitude),\(endLocation.coordinate.longitude)"
        
        var url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=\(Constants.APIKey.rawValue)"
        //&waypoints=optimize:true%7C\(startLocation2)%7C\(destinationLocation2)%7C28.641980,77.249560
        
        if let wayPoints = wayPoints{
            url.append("&waypoints=optimize:true")
            for wayPoint in wayPoints{
                let wayPointString = "\(wayPoint.coordinate.latitude),\(wayPoint.coordinate.longitude)"
                url.append("%7C\(wayPointString)")
            }
        }
        
        print(url)
        
        Alamofire.request(url).responseJSON { response in
            
            var routes: [JSON] = []
            //let bounds: [String : JSON]?
            do {
                let json = try JSON(data: response.data!)
                routes = json["routes"].arrayValue
                completion(routes)
            } catch let error {
                failure("Routes Not found with \(error)")
            }
        }
    }
    
    //MARK: Google Geocode API
    func getCoordinates(from address:String, completion: @escaping CordinatesCompletionBlock, failure: @escaping NetworkFailureBlock){
        
        let key : String = Constants.APIKey.rawValue
        let postParameters:[String: Any] = [ "address": address,"key":key]
        let url : String = "https://maps.googleapis.com/maps/api/geocode/json"
        
        var location: CLLocation? = nil
        
        Alamofire.request(url, method: .get, parameters: postParameters, encoding: URLEncoding.default, headers: nil).responseJSON {  response in
            
            if let receivedResults = response.result.value
            {
                let resultParams = JSON(receivedResults)
                print(resultParams) // RESULT JSON
            
                let latitute  = resultParams["results"][0]["geometry"]["location"]["lat"].doubleValue
                let longitute = resultParams["results"][0]["geometry"]["location"]["lng"].doubleValue
                
                location = CLLocation(latitude: latitute, longitude: longitute)
                
                completion(location)
            }else{
                failure("Could Not get Cordinates")
            }
        }
    }
    
    //MARK: Google Distancematrix API
    func getDistance(startLocation: CLLocation, endLocation: CLLocation, wayPoints: [CLLocation]?,completion: @escaping DistanceComplitionBlock, failure: @escaping NetworkFailureBlock)
    {
        let origin = "\(startLocation.coordinate.latitude),\(startLocation.coordinate.longitude)"
        let destination = "\(endLocation.coordinate.latitude),\(endLocation.coordinate.longitude)"
        
        var url = "https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&key=\(Constants.APIKey.rawValue)&origins=\(origin)&destinations=\(destination)"
        
        if let wayPoints = wayPoints{
            for wayPoint in wayPoints{
                let wayPointString = "\(wayPoint.coordinate.latitude),\(wayPoint.coordinate.longitude)"
                url.append("%7C\(wayPointString)")
            }
        }
        
        print(url)
        
        Alamofire.request(url).responseJSON { response in
            do {
                let json = try JSON(data: response.data!)
                print(json)
                completion([])
            } catch let error {
                failure("Distances Not found with \(error)")
            }
        }
    }
    
}

/**** Test Data */

//let origin = "\(startLocation.coordinate.latitude),\(startLocation.coordinate.longitude)"
//let destination = "\(endLocation.coordinate.latitude),\(endLocation.coordinate.longitude)"
//
//let startLocation1 = "Parliament+Of+India,New+Delhi"
//let destination1 = "NDLS+Railway+Station,+New+Delhi"
//let startLocation2 = "India+Gate,+New+Delhi"
//let destinationLocation2 = "Indira+Gandhi+International+Airport,New+Delhi"
//let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=AIzaSyCeZMQyak_ixe9tVcsedmXEjfvOLwofAiA"
//let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(startLocation1)&destination=\(destination1)&mode=driving&key=\(Constants.APIKey.rawValue)&waypoints=optimize:true%7C\(startLocation2)%7C\(destinationLocation2)%7C28.641980,77.249560"
//let url = "https://maps.googleapis.com/maps/api/directions/json?origin=Disneyland&destination=Universal+Studios+Hollywood&key=AIzaSyCeZMQyak_ixe9tVcsedmXEjfvOLwofAiA"
//let url = "https://maps.googleapis.com/maps/api/directions/json?origin=New Delhi Railway Station&destination=New Delhi Airport&mode=driving&key=AIzaSyCeZMQyak_ixe9tVcsedmXEjfvOLwofAiA"
//let url = "http://maps.googleapis.com/maps/api/directions/json?origin=Adelaide,SA&destination=Adelaide,SA&waypoints=optimize:true|Barossa+Valley,SA|Clare,SA|Connawarra,SA|McLaren+Vale,SA&sensor=false&key=AIzaSyCeZMQyak_ixe9tVcsedmXEjfvOLwofAiA"
//        let rajGhat = "28.641980,77.249560"
//        let indiaGate = "28.613195,77.229488"
//        let armyHospital = "28.613841,77.132252"
//let url = "https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=40.6655101,-73.89188969999998&destinations=40.6905615%2C-73.9976592%7C40.6905615%2C-73.9976592%7C40.6905615%2C-73.9976592%7C40.6905615%2C-73.9976592%7C40.6905615%2C-73.9976592%7C40.6905615%2C-73.9976592%7C40.659569%2C-73.933783%7C40.729029%2C-73.851524%7C40.6860072%2C-73.6334271%7C40.598566%2C-73.7527626%7C40.659569%2C-73.933783%7C40.729029%2C-73.851524%7C40.6860072%2C-73.6334271%7C40.598566%2C-73.7527626&key=AIzaSyCeZMQyak_ixe9tVcsedmXEjfvOLwofAiA"
