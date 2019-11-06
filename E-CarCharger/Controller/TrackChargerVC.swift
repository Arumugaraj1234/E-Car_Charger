//
//  TrackChargerVC.swift
//  E-CarCharger
//
//  Created by MacBook Pro on 2019-11-06.
//  Copyright © 2019 Peach. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps

class TrackChargerVC: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var mapView: GMSMapView!
    
    //MARK: Google Map Related Variables
    let locationManager = CLLocationManager()
    var pathToCentre: GMSPath?
    var isMapCentered: Bool = true //Tracker for map centered position
    var myCurrentLatitude: Double?
    var myCurrentLongitude: Double?

    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        mapView.delegate = self
        mapView.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.new, context: nil)
        getNearByChargers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setNaviagtionBarTitle(title: "Charger Locatioin")
    }
    
    @IBAction func onBackBtnPressed(sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func getNearByChargers() {
        //Current Locatiion: Optional(19.0176147), Optional(72.8561644)
        let chargerLocation = CLLocationCoordinate2DMake(19.017919, 72.857248)
        let nearByChargers = [chargerLocation]
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

}

extension TrackChargerVC: CLLocationManagerDelegate {
    
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

extension TrackChargerVC: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        //Creating Route
    }
    
//    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
//        if self.isMapCentered == false {
//            self.centreMapBtn.fadeTo(alphaValue: 1.0, withDuration: 0.2)
//        }
//        else {
//            self.centreMapBtn.fadeTo(alphaValue: 0.0, withDuration: 0.2)
//        }
//        self.isMapCentered = false
//    }
    
}
