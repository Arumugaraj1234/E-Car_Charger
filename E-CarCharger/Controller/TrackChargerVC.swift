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
import Razorpay

protocol BackFromTrackChargerDelegate {
    func updateIfAnyOrderInService()
}

class TrackChargerVC: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var chargerNameLbl: UILabel!
    @IBOutlet weak var chargingView: UIView!
    @IBOutlet weak var chargingLbl:UILabel!
    @IBOutlet weak var fareShowingView: UIView!
    @IBOutlet weak var totalTimeLbl: UILabel!
    @IBOutlet weak var totalFareLbl: UILabel!
    @IBOutlet weak var vehicleImage: UIImageView!
    @IBOutlet weak var otpLbl: UILabel!
    
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
    var timerToUpdateOrderStatus: Timer?
    var timerForChargingLbl: Timer?
    var flagForChargerLbl = 0
    var orderId = 0
    var flagToShowChargingView = 0
    var razorpay: Razorpay?
    var currentOrder: OrderModel?
    var delegate: BackFromTrackChargerDelegate?
    
    let locationService = LocationService.shared
    let webService = WebRequestService.shared

    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        mapView.delegate = self
        //mapView.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.new, context: nil)
        chargingView.isHidden = true
        fareShowingView.isHidden = true
        razorpay = Razorpay.initWithKey("rzp_test_DmW0jpqP1WI399", andDelegate: self)
        if webService.orderStatusForOrderInService == 2 {
            enableChargingView(with: true)
            if timerToUpdateOrderStatus == nil {
                timerToUpdateOrderStatus = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.trackOrderStatus), userInfo: nil, repeats: true)
            }
        }
        else if webService.orderStatusForOrderInService == 3 {
            getFareForOrder()
        }
        else {
            if timerToUpdateOrderStatus == nil {
                timerToUpdateOrderStatus = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.trackOrderStatus), userInfo: nil, repeats: true)
            }
            trackChargerWithTimer()
        }
        updateChargerDetails()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setNaviagtionBarTitle(title: "Track Charger")
    }
    
    @IBAction func onBackBtnPressed(sender: Any) {
        if let _ = timer {
            timer?.invalidate()
            timer = nil
        }
        if let _ = timerToUpdateOrderStatus {
            timerToUpdateOrderStatus?.invalidate()
            timerToUpdateOrderStatus = nil
        }
        if let _ = timerForChargingLbl {
            timerForChargingLbl?.invalidate()
            timerForChargingLbl = nil
            
        }
        delegate?.updateIfAnyOrderInService()
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func onCenterBtnPressed(sender: UIButton) {
        drawRoute()
    }
    
    @IBAction func onPayByCashBtnPressed(_ sender: RoundedBtn) {
        performSegue(withIdentifier: TRACKVC_TO_HISTORYVC, sender: self)
    }
    
    @IBAction func onEPaymentBtnPressed(_ sender: RoundedBtn) {
        let options: [String:Any] = [
            "amount" : "1000", //mandatory in paise like:- 1000 paise ==  10 rs
            "description": "Charged Amount",
            "image": "https://url-to-image.png",
            "name": "Mi-Charger",
            "prefill": [
            "contact": "9797979797",
            "email": "foo@bar.com"
            ],
            "theme": [
                "color": "#F37254"
            ]
        ]
        razorpay?.open(options)
    }
    
    @IBAction func onCallBtnPressed(_ sender: UIButton) {
        guard let order = self.currentOrder else {return}
        guard let number = URL(string: "tel://" + order.chargerMobileNo) else { return }
        UIApplication.shared.open(number)
    }
    
    @IBAction func onComposeMessageBtnPressed(_ sender: UIButton) {
        guard let order = self.currentOrder else {return}
        MessageService.shared.displayMessageInterface(vc: self, mobileNo: order.chargerMobileNo)
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
            webService.getOrderInfo(orderId: orderId) { (status, message, data) in
                if status == 1 {
                    guard let orderModel = data else {return}
                    self.currentOrder = orderModel
                    self.chargerNameLbl.text = orderModel.chargerName
                    self.vehicleImage.downloadedFrom(link: orderModel.vehicleImageLink)
                    self.otpLbl.text = "OTP: \(orderModel.otp)"
                }
            }
        }
        else {
            makeToast(message: "Your internet is weak or unavailable. Please check & try again!", time: 3.0, position: .bottom, textColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
        }
    }
    
    @objc func trackCharger() {
        if checkInternetAvailablity() {
            webService.trackCharger(chargerId: chargerId) { (status, Message, data) in
                if status == 1 {
                    //let myLocatiion = CLLocationCoordinate2DMake(13.073383, 80.260889)
                    let myLocation = CLLocationCoordinate2DMake(self.locationService.myCurrentLatitude, self.locationService.myCurrentLongitude)
                    let chargerLocation = CLLocationCoordinate2DMake((data?.currentLatitude)!, (data?.currentLongitude)!)
                    LocationService.shared.getDirectionsFromgeoCode(originLat: myLocation.latitude, originLon: myLocation.longitude, destinalat: chargerLocation.latitude, destLon: chargerLocation.longitude, wayPoints: [], travelMode: "driving" as AnyObject) { (success) in
                        if success {
                            DispatchQueue.main.async {
                                print("Poly Line Success")
                                self.mapView.clear()
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
            makeToast(message: "Your internet is weak or unavailable. Please check & try again!", time: 3.0, position: .bottom, textColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
        }
    }
    
    func configureMapAndMarkersForRoute(chargerCoOrdinates: CLLocationCoordinate2D) {
        let myLocatiion = CLLocationCoordinate2DMake(locationService.myCurrentLatitude, locationService.myCurrentLongitude)
        mapView.camera = GMSCameraPosition.camera(withTarget: myLocatiion, zoom: 15.0)
        
        originMaker = GMSMarker(position: myLocatiion)
        originMaker?.map = self.mapView
        originMaker?.icon = UIImage(named: "trackIcon")
        originMaker?.snippet = "User"
        self.mapView.selectedMarker = originMaker
        
        let chargerLocation = chargerCoOrdinates
        destinationMarker = GMSMarker(position: chargerLocation)
        destinationMarker?.map = self.mapView
        destinationMarker?.icon = UIImage(named: "chargerIcon")
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
        
        let gmsCameraUpdate = GMSCameraUpdate.fit(bounds, withPadding: 60.0)
        mapView.moveCamera(gmsCameraUpdate)
    }
    
    @objc
    func trackOrderStatus() {
        webService.checkOrderForCompleteCharging(orderId: self.orderId) { (status, message, oStatus, data) in
            if status == 1 {
                guard let orderStatus = oStatus else {return}
                self.webService.orderStatusForOrderInService = orderStatus
                let index = IndexPath(row: 0, section: 0)
                if let cell = self.tableView.cellForRow(at: index) as? ChargerStatusCell {
                    cell.configureCell(status: orderStatus)
                }
                self.tableView.reloadData()
                if orderStatus == 2 {
                    if let _ = self.timer {
                        self.timer?.invalidate()
                        self.timer = nil
                    }
                    if self.flagToShowChargingView == 0 {
                        self.enableChargingView(with: true)
                    }
                    self.flagToShowChargingView = 1
                }
                else if orderStatus == 3 {
                    if let _ = self.timer {
                        self.timer?.invalidate()
                        self.timer = nil
                    }
                    if let _ = self.timerToUpdateOrderStatus {
                        self.timerToUpdateOrderStatus?.invalidate()
                        self.timerToUpdateOrderStatus = nil
                    }
                    if let _ = self.timerForChargingLbl {
                        self.timerForChargingLbl?.invalidate()
                        self.timerForChargingLbl = nil
                        
                    }
                    guard let fareModel = data else {return}
                    self.totalTimeLbl.text = fareModel.timeTookToCharge
                    let rupee = "\u{20B9}"
                    self.totalFareLbl.text = rupee + fareModel.totalFare
                    self.enableFareShowingView(with: true)
                }
            }
        }
    }
    
    func enableChargingView(with status: Bool) {
        if status {
            UIView.animate(withDuration: 3.0) {
                self.chargingView.isHidden = false
            }
            timerForChargingLbl = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.timerToUpdateChargingLbl), userInfo: nil, repeats: true)
        }
        else {
            chargingView.isHidden = true
            if let _ = timerForChargingLbl {
                self.timerForChargingLbl?.invalidate()
                self.timerForChargingLbl = nil
                
            }
        }
    }
    
    @objc
    func timerToUpdateChargingLbl() {
        if flagForChargerLbl == 0 {
            chargingLbl.text = "Charging."
            flagForChargerLbl = 1
        }
        else if flagForChargerLbl == 1 {
            chargingLbl.text = "Charging.."
            flagForChargerLbl = 2
        }
        else {
            chargingLbl.text = "Charging..."
            flagForChargerLbl = 0
        }
    }
    
    func enableFareShowingView(with status: Bool) {
        if status {
            UIView.animate(withDuration: 3.0) {
                self.fareShowingView.isHidden = false
            }
        }
        else {
            fareShowingView.isHidden = true
        }
    }
    
    func getFareForOrder() {
        webService.checkOrderForCompleteCharging(orderId: self.orderId) { (status, message, oStatus, data) in
            if status == 1 {
                guard let orderStatus = oStatus else {return}
                let index = IndexPath(row: 0, section: 0)
                if let cell = self.tableView.cellForRow(at: index) as? ChargerStatusCell {
                    cell.configureCell(status: orderStatus)
                }
                self.tableView.reloadData()

                if orderStatus == 3 {
                    guard let fareModel = data else {return}
                    let rupee = "\u{20B9}"
                    self.totalTimeLbl.text = fareModel.timeTookToCharge
                    self.totalFareLbl.text = rupee + fareModel.totalFare
                    self.enableFareShowingView(with: true)
                }
            }
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
        //mapView.camera = GMSCameraPosition.camera(withTarget: myLocation.coordinate, zoom: 15.0)
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

extension TrackChargerVC: RazorpayPaymentCompletionProtocol {
    func onPaymentError(_ code: Int32, description str: String) {
        _ = SweetAlert().showAlert("Error", subTitle: "Code: \(code)\n\(str)", style: .none)
    }
    
    func onPaymentSuccess(_ payment_id: String) {
        _ = SweetAlert().showAlert("Paid", subTitle: "Payment success", style: .none)
    }
    
    
}
