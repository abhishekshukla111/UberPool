//
//  ArchiveUtility.swift
//  UberPool
//
//  Created by abhishek.b.shukla on 15/02/19.
//  Copyright © 2019 Abhishek Shukla. All rights reserved.
//

import Foundation

class ArchiveUtility {
    
    static let shared = ArchiveUtility()
    let fileManager = FileManager.default
    let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
    let path: String?
    
    init() {
        path = documentDirectory.appending("/History.plist")
        print("Path: \(path)")
        
        createPlist()
    }
    
    func createPlist() {
        if (!fileManager.fileExists(atPath: path!)) {
            let arrayContent:[[String: Any]] = [[:]]// ["Date": Date(), "StartLocation":"","EndLocation":""]
            let plistContent = NSArray(array: arrayContent)
            let success:Bool = plistContent.write(toFile: path!, atomically: true)
            if success {
                print("file has been created!")
            }else{
                print("unable to create the file")
            }
        }else{
            print("file already exist")
        }
    }
    
    func readPlist() -> [[String: Any]]? {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path!)) else {
            return nil
        }
        guard let result = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [[String: Any]] else {
            return nil
        }
        print(result as Any)
        
        return result
    }
    
    func updateData(data: [String: Any]){
        var plistData = readPlist()
        
        plistData?.append(data)
        
        let plistContent = NSArray(array: plistData!)
        let success:Bool = plistContent.write(toFile: path!, atomically: true)
        if success {
            print("file has been created!")
        }else{
            print("unable to create the file")
        }
        
    }
    //        let content = result! as NSArray
    //        result?.append(["Abhishke":"Shukla"])
    //        let success:Bool = content.write(toFile: filePath, atomically: true)
    //        if success {
    //            print("file has been created!")
    //        }else{
    //            print("unable to create the file")
    //        }
    
    //appendDataToPlist(fileURL)
    
    
    //    func appendDataToPlist(_ fileURL: URL){
    //        var dataDic = readPlist(fileURL)
    //        //dataDic.
    //    }
    
   
    
    
}
