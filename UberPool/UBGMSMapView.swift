//
//  UBGMSMapView.swift
//  UberPool
//
//  Created by Abhishek Shukla on 2/15/19.
//  Copyright © 2019 Abhishek Shukla. All rights reserved.
//

import Foundation
import GoogleMaps


class UBGMSMapView: GMSMapView {

    override func awakeFromNib() {
        super.awakeFromNib()
        //custom logic goes here
        
        self.isMyLocationEnabled = true
        self.settings.myLocationButton = true
        self.settings.compassButton = true
        self.settings.zoomGestures = true

    }
}
