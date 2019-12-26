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
import SideMenu

class NearByChargersVC: UIViewController {
    
    //MARK: Other Outlets
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var centreMapBtn: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var existOrderView: UIView!
    @IBOutlet weak var existOrderVehicleImg: UIImageView!
    @IBOutlet weak var existOrderChargerNameLbl: UILabel!
    @IBOutlet weak var existOrderRefNoLbl: UILabel!
    @IBOutlet weak var existOrderOtpLbl: UILabel!
    @IBOutlet weak var menuBtn: UIBarButtonItem!
    @IBOutlet weak var collectionViewHeightContraint: NSLayoutConstraint!
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue){}
        
    //MARK: Google Map Related Variables
    let locationManager = CLLocationManager()
    var pathToCentre: GMSPath?
    var isMapCentered: Bool = true //Tracker for map centered position
    var myCurrentLatitude: Double?
    var myCurrentLongitude: Double?
    
    //MARK: General Variables
    let webService = WebRequestService.shared
    let locationService = LocationService.shared
    var vehicles = [VehicleTypeModel]()
    var selectedVehicle: VehicleTypeModel?
    var bookOrder: OrderBookModel?
    var timer: Timer?
    var chargerId: Int?
    var acceptedOrderId: Int?
    var chargerCountFlag = 0
    var timerToFindNearByChargers: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LocationService.shared.authorize()
        locationManager.delegate = self
        mapView.delegate = self
        mapView.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.new, context: nil)
        startAnimate(with: "")
        existOrderView.isHidden = true
        collectionViewHeightContraint.constant = 70.0
        if timerToFindNearByChargers == nil {
            timerToFindNearByChargers = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(self.getNearByChargers), userInfo: nil, repeats: true)
        }
        checkForOrderInService()
        getVehicleTypes()
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.goToTrackChargerForExistOrder(_:)))
        existOrderView.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setNaviagtionBarTitle(title: "Nearby Chargers")
    }
    
    //MARK: IBAction Connectiions
    
    @IBAction func onCentreMapBtnPressed(sender: UIButton) {
        if self.pathToCentre == nil {
            let currentCoordinates = CLLocationCoordinate2DMake(locationService.myCurrentLatitude, locationService.myCurrentLongitude)
            mapView.camera = GMSCameraPosition.camera(withTarget: currentCoordinates, zoom: 15.0)
        } else {
            let bounds = GMSCoordinateBounds(path: pathToCentre!)
            mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 100.0))
        }
        
        self.centreMapBtn.fadeTo(alphaValue: 0.0, withDuration: 0.2)
        self.isMapCentered = true
    }
    
    @IBAction func menuBtnPressed(_ sender: Any) {
        let menu = storyboard!.instantiateViewController(withIdentifier: "SideMenu") as! UISideMenuNavigationController
        menu.sideMenuManager.menuPresentMode = .menuDissolveIn
        present(menu, animated: true, completion: nil)
    }
    
    //MARK: Functions
    
    @objc
    func getNearByChargers() {
        let myLocation = CLLocationCoordinate2DMake(locationService.myCurrentLatitude, locationService.myCurrentLongitude)
        if checkInternetAvailablity() {
            webService.getNearByChargers(with: myLocation.latitude, and: myLocation.longitude) { (status, message, data) in
                if status == 1 {
                    let nearestChargers = data!
                    self.setLocationMarkerForChargers(chargers: nearestChargers)
                }
            }
        }
        else {
            makeToast(message: "Your internet is weak or unavailable. Please check & try again!", time: 3.0, position: .bottom, textColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
        }
    }
    
    func getVehicleTypes() {
        if checkInternetAvailablity() {
            webService.getVehicleType { (status, message, data) in
                self.stopAnimating()
                if status == 1 {
                    self.vehicles = data!
                    self.collectionView.reloadData()
                }
                else {
                    print(message)
                }
            }
        }
        else {
            stopAnimating()
            makeToast(message: "Your internet is weak or unavailable. Please check & try again!", time: 3.0, position: .bottom, textColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
        }
    }
    
    func setLocationMarkerForChargers(chargers: [ChargerModel]) {
        mapView.clear()
        for charger in chargers {
            let driverLocationMarker = GMSMarker()
            let position = CLLocationCoordinate2DMake(charger.currentLatitude, charger.currentLongitude)
            driverLocationMarker.position = position
            driverLocationMarker.icon = UIImage(named: "chargerIcon")
            driverLocationMarker.map = mapView
        }
    }
    
    func updatePersonalDetails() {
        let personalDetailsVc = storyboard?.instantiateViewController(withIdentifier: "PersonalDetailsVC") as! PersonalDetailsVC
        personalDetailsVc.modalPresentationStyle = .overCurrentContext
        personalDetailsVc.delegate = self
        if UIDevice.current.userInterfaceIdiom == .pad {
            personalDetailsVc.preferredContentSize = CGSize(width: 450.0, height: 750.0)
        }
        self.present(personalDetailsVc, animated: true)
    }
    
    func checkForOrderInService() {
        webService.checkForAnyOrderInService(userId: webService.userId) { (status, message, data) in
            if status == 1 {
                if let order = data {
                    self.existOrderView.isHidden = false
                    self.collectionViewHeightContraint.constant = 0
                    self.chargerId = order.chargerId
                    self.existOrderVehicleImg.downloadedFrom(link: order.vehicleImageLink)
                    self.existOrderChargerNameLbl.text = order.chargerName
                    self.existOrderRefNoLbl.text = "Order Ref. No: \(order.orderId)"
                    self.existOrderOtpLbl.text = "OTP: \(order.otp)"
                    self.acceptedOrderId = order.orderId
                }
            }
        }
    }
    
    func bookCharger() {
        startAnimate(with: "")
        if checkInternetAvailablity() {
            let myLocation = CLLocationCoordinate2DMake(locationService.myCurrentLatitude, locationService.myCurrentLongitude)
            webService.bookCharger(userId: webService.userId, vehicleId: (selectedVehicle?.id)!, userLocation: myLocation) { (status, message, data) in
                if status == 1 {
                    self.bookOrder = data!
                    guard self.timer == nil else {return}
                    self.timer = Timer.scheduledTimer(timeInterval: 10,
                                                      target: self,
                                                      selector: #selector(self.checkChargerAcceptanceForBookedOrder),
                                                      userInfo: nil, repeats: true)
                }
                else {
                    self.stopAnimating()
                    _ = SweetAlert().showAlert("Failed!", subTitle: message, style: .none)
                    //self.makeToast(message: "Oops! \(message)", time: 3.0, position: .bottom)
                }
            }
        }
        else {
            stopAnimating()
            makeToast(message: "Your internet is weak or unavailable. Please check & try again!", time: 3.0, position: .bottom, textColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
        }
    }
    
    @objc func checkChargerAcceptanceForBookedOrder() {
        chargerCountFlag = chargerCountFlag + 1
        print(chargerCountFlag)
        if chargerCountFlag < 7 {
            let myLocation = CLLocationCoordinate2DMake(locationService.myCurrentLatitude, locationService.myCurrentLongitude)
            webService.checkBookingStatus(orderId: (bookOrder?.id)!, vehicleType: (bookOrder?.vehicleId)!, userLocation: myLocation) { (status, message, data) in
                if status == 1 {
                    self.stopAnimating()
                    self.timer?.invalidate()
                    self.timer = nil
                    self.chargerId = data
                    self.acceptedOrderId = self.bookOrder?.id
                    self.webService.orderStatusForOrderInService = 1
                    self.performSegue(withIdentifier: NEARBY_CHARGERS_TO_TRACK_CHARGER, sender: self)
                }
            }
        }
        else {
            chargerCountFlag = 0
            self.timer?.invalidate()
            self.timer = nil
            self.webService.autoCancelOfOrder(orderId: (bookOrder?.id)!) { (status, message) in
                self.stopAnimating()
                _ = SweetAlert().showAlert("Failed!", subTitle: message, style: .none)
               // self.makeToast(message: message, time: 3.0, position: .bottom)
            }
        }
    }
    
    @objc
    func goToTrackChargerForExistOrder(_ sender: UITapGestureRecognizer) {
        
        self.performSegue(withIdentifier: NEARBY_CHARGERS_TO_TRACK_CHARGER, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == NEARBY_CHARGERS_TO_TRACK_CHARGER {
            let trackChargerVc = segue.destination as! TrackChargerVC
            trackChargerVc.chargerId = self.chargerId!
            trackChargerVc.myCurrentLatitude = locationService.myCurrentLatitude
            trackChargerVc.myCurrentLongitude = locationService.myCurrentLongitude
            trackChargerVc.orderId = self.acceptedOrderId!
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

extension NearByChargersVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return vehicles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VehicleTypeCell", for: indexPath) as? VehicleTypeCell else {return UICollectionViewCell()}
        let vehicleType = vehicles[indexPath.row]
        cell.configureCell(vehicle: vehicleType)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedVehicleType = vehicles[indexPath.row]
        self.selectedVehicle = selectedVehicleType
        var fName = ""
        var lName = ""
        var email = ""
        if let personal = webService.userDetails {
            fName = personal["firstName"] ?? ""
            lName = personal["lastName"] ?? ""
            email = personal["email"] ?? ""
        }
        if fName == "" || lName == "" || email == "" {
           updatePersonalDetails()
        }
        else {
            bookCharger()
        }
    }

}

extension NearByChargersVC: PersonalDetailsDelegate {
    func personalDetailsUpdated() {
        bookCharger()
    }
    
    
}
