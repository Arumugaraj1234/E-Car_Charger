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
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var chargerNameLbl: UILabel!
    
    //MARK: Google Map Related Variables
    let locationManager = CLLocationManager()
    var pathToCentre: GMSPath?
    var isMapCentered: Bool = true //Tracker for map centered position
    var myCurrentLatitude: Double?
    var myCurrentLongitude: Double?
    
    var originMaker: GMSMarker?
    var destinationMarker: GMSMarker?
    var routePolyLine: GMSPolyline?
    var markersArray = [GMSMarker]()
    var wayPointsArray = [String]()
    var chargerId = 0
    var timer: Timer?
    
    let locationService = LocationService.shared
    let webService = WebRequestService.shared

    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        mapView.delegate = self
        mapView.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.new, context: nil)
        updateChargerDetails()
        trackChargerWithTimer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setNaviagtionBarTitle(title: "Track Charger")
    }
    
    @IBAction func onBackBtnPressed(sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func onCenterBtnPressed(sender: UIButton) {
        drawRoute()
    }
    
    func trackChargerWithTimer() {
        guard self.timer == nil else {return}
        self.timer = Timer.scheduledTimer(timeInterval: 5,
                                          target: self,
                                          selector: #selector(self.trackCharger),
                                          userInfo: nil, repeats: true)
    }
    
    func updateChargerDetails() {
        if checkInternetAvailablity() {
            webService.trackCharger(chargerId: chargerId) { (status, message, data) in
                if status == 1 {
                    self.chargerNameLbl.text = (data?.firstName)! + " " + (data?.lastName)!
                }
            }
        }
        else {
            makeToast(message: "Your internet is weak or unavailable. Please check & try again!", time: 3.0, position: .bottom)
        }
    }
    
    @objc func trackCharger() {
        if checkInternetAvailablity() {
            webService.trackCharger(chargerId: chargerId) { (status, Message, data) in
                if status == 1 {
                    let myLocatiion = CLLocationCoordinate2DMake(13.073383, 80.260889)
                    let chargerLocation = CLLocationCoordinate2DMake((data?.currentLatitude)!, (data?.currentLongitude)!)
                    LocationService.shared.getDirectionsFromgeoCode(originLat: myLocatiion.latitude, originLon: myLocatiion.longitude, destinalat: chargerLocation.latitude, destLon: chargerLocation.longitude, wayPoints: [], travelMode: "driving" as AnyObject) { (success) in
                        if success {
                            DispatchQueue.main.async {
                                print("Poly Line Success")
                                self.configureMapAndMarkersForRoute(chargerCoOrdinates: chargerLocation)
                                self.drawRoute()
                            }
                        }
                        else {
                            print("Poly line failed")
                        }
                    }
                }
            }
        }
        else {
            makeToast(message: "Your internet is weak or unavailable. Please check & try again!", time: 3.0, position: .bottom)
        }
    }
    
    func configureMapAndMarkersForRoute(chargerCoOrdinates: CLLocationCoordinate2D) {
        let myLocatiion = CLLocationCoordinate2DMake(13.073383, 80.260889)
        //let myLocatiion = CLLocationCoordinate2DMake(myCurrentLatitude!, myCurrentLongitude!)
        mapView.camera = GMSCameraPosition.camera(withTarget: myLocatiion, zoom: 15.0)
        
        originMaker = GMSMarker(position: myLocatiion)
        originMaker?.map = self.mapView
        originMaker?.icon = UIImage(named: "trackIcon")
        //originMaker?.title = AuthService.instance.originAddress
        originMaker?.snippet = "User"
        self.mapView.selectedMarker = originMaker
        
        //let chargerLocation = CLLocationCoordinate2DMake(13.078519, 80.261002)
        let chargerLocation = chargerCoOrdinates
        destinationMarker = GMSMarker(position: chargerLocation)
        destinationMarker?.map = self.mapView
        destinationMarker?.icon = UIImage(named: "chargerIcon")
        //destinationMarker?.title = AuthService.instance.destinationAddress
        destinationMarker?.snippet = "John"
        self.mapView.selectedMarker = destinationMarker
        
        
        if wayPointsArray.count > 0 {
            for wapoint in wayPointsArray {
                let reqCoOrdinate = wapoint.components(separatedBy: ",")
                let lat: Double = Double(reqCoOrdinate[0])!
                let lon:Double = Double(reqCoOrdinate[1])!
                
                let marker = GMSMarker(position: CLLocationCoordinate2DMake(lat, lon))
                marker.map = mapView
                marker.icon = GMSMarker.markerImage(with: UIColor.darkGray)
                markersArray.append(marker)
            }
        }
    }
    
    func drawRoute() {
        let route = LocationService.shared.overViewPolyLine["points"] as! String
        print(route)
        let path: GMSPath = GMSPath(fromEncodedPath: route)!
        routePolyLine = GMSPolyline(path: path)
        routePolyLine?.strokeColor = UIColor.black
        routePolyLine?.strokeWidth = 2.0
        routePolyLine?.map = mapView
        self.pathToCentre = path
        let bounds = GMSCoordinateBounds(path: path)
        //mapView.animate(with: GMSCameraUpdate.fit(bounds))
        mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 60.0))
        //self.animateFromToContainerView(shoulShow: false)
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Get Locations")
        let defaultLocation = CLLocation(latitude: 0.0, longitude: 0.0)
        let location: CLLocation = locations.last ?? defaultLocation
        myCurrentLatitude = location.coordinate.latitude
        myCurrentLongitude = location.coordinate.longitude
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

extension TrackChargerVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChargerStatusCell", for: indexPath) as? ChargerStatusCell else {return UITableViewCell()}
        return cell
    }
}
