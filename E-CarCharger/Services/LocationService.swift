//
//  LocationService.swift
//  E-CarCharger
//
//  Created by MacBook Pro on 2019-10-31.
//  Copyright © 2019 Peach. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class LocationService: NSObject {
    
    private override init() {}
    static let shared = LocationService()
    
    let locationManager = CLLocationManager()
    
    func setGoogleApiKeys() {
        GMSServices.provideAPIKey("AIzaSyDUgw31MfDV88qEnxUqInF8VVElUAjqgpg")
        GMSPlacesClient.provideAPIKey("AIzaSyDUgw31MfDV88qEnxUqInF8VVElUAjqgpg")
    }
    
    func authorize() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
    }
    
}
