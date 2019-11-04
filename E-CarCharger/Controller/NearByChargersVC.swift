//
//  NearByChargersVC.swift
//  E-CarCharger
//
//  Created by MacBook Pro on 2019-10-30.
//  Copyright © 2019 Peach. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps

class NearByChargersVC: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var centreMapBtn: UIButton!
    
    //MARK: General Variables
    let otherService = OtherService.shared
    var vehicleType = 0
    
    //MARK: Google Map Related Variables
    let locationManager = CLLocationManager()
    var pathToCentre: GMSPath?
    var isMapCentered: Bool = true //Tracker for map centered position
    var myCurrentLatitude: Double?
    var myCurrentLongitude: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LocationService.shared.authorize()
        locationManager.delegate = self
        mapView.delegate = self
        mapView.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.new, context: nil)
        getNearByChargers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setNaviagtionBarTitle(title: "NEARBY CHARGERS")
    }
    
    //MARK: IBAction Connectiions
    
    @IBAction func onCentreMapBtnPressed(sender: UIButton) {
        if self.pathToCentre == nil {
            let currentCoordinates = CLLocationCoordinate2DMake(myCurrentLatitude!, myCurrentLongitude!)
            mapView.camera = GMSCameraPosition.camera(withTarget: currentCoordinates, zoom: 15.0)
        } else {
            let bounds = GMSCoordinateBounds(path: pathToCentre!)
            mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 100.0))
        }
        
        self.centreMapBtn.fadeTo(alphaValue: 0.0, withDuration: 0.2)
        self.isMapCentered = true
    }
    
    @IBAction func onBookChargerBtnPressed(sender: UIButton) {
        getVehicleType()
    }
    
    
    //MARK: Functions
    func getNearByChargers() {
        //Current Locatiion: Optional(19.0176147), Optional(72.8561644)
        let charger1 = CLLocationCoordinate2DMake(19.017919, 72.857248)
        let charger2 = CLLocationCoordinate2DMake(19.019542, 72.854255)
        let nearByChargers = [charger1, charger2]
        setLocationMarkerForChargers(chargers: nearByChargers)
    }
    
    func setLocationMarkerForChargers(chargers: [CLLocationCoordinate2D]) {
        for charger in chargers {
            let driverLocationMarker = GMSMarker()
            driverLocationMarker.position = charger
            driverLocationMarker.icon = UIImage(named: "chargerIcon")
            driverLocationMarker.map = mapView
        }
    }
    
    func getVehicleType() {
        let alert = UIAlertController(title: "Select your vehicle type", message: nil , preferredStyle: .alert)
        let twoWheelerAction = UIAlertAction(title: "Bike", style: .default) { (alert) in
            self.vehicleType = 1
            self.bookCharger()
        }
        let fourWheelerAction = UIAlertAction(title: "Car", style: .default) { (alert) in
            self.vehicleType = 2
            self.bookCharger()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert : UIAlertAction!) in
        }
        alert.addAction(twoWheelerAction)
        alert.addAction(fourWheelerAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func bookCharger() {
        if otherService.isLoggedIn {
            print("Show the Charger details")
        } else {
            
        }
    }
    
}

extension NearByChargersVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            mapView.isMyLocationEnabled = true
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        let myLocation: CLLocation = change![NSKeyValueChangeKey.newKey] as! CLLocation
        myCurrentLatitude = myLocation.coordinate.latitude
        myCurrentLongitude = myLocation.coordinate.longitude
        mapView.camera = GMSCameraPosition.camera(withTarget: myLocation.coordinate, zoom: 15.0)
        mapView.settings.compassButton = true
    }
    
}

extension NearByChargersVC: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        //Creating Route
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        if self.isMapCentered == false {
            self.centreMapBtn.fadeTo(alphaValue: 1.0, withDuration: 0.2)
        }
        else {
            self.centreMapBtn.fadeTo(alphaValue: 0.0, withDuration: 0.2)
        }
        self.isMapCentered = false
    }
    
}
