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
