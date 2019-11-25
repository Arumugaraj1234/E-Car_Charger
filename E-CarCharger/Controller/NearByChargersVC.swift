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
    
    //MARK: Side Screen Outlets
    @IBOutlet var gestureScreenEdgePan: UIScreenEdgePanGestureRecognizer!
    @IBOutlet weak var viewBlack: UIView!
    @IBOutlet weak var viewMenu: UIView!
    @IBOutlet weak var constraintMenuLeft: NSLayoutConstraint!
    @IBOutlet weak var constraintMenuWidth: NSLayoutConstraint!
    @IBOutlet weak var menuBtn: UIBarButtonItem!
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue){}

    //MARK: Other Outlets
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var centreMapBtn: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var existOrderView: UIView!
    @IBOutlet weak var existOrderVehicleImg: UIImageView!
    @IBOutlet weak var existOrderChargerNameLbl: UILabel!
    @IBOutlet weak var existOrderRefNoLbl: UILabel!
    
    //MARK: Hamburger Menu Variables
    let maxBlackViewAlpha: CGFloat = 0.5
    let animationDuration: TimeInterval = 0.3
    var isLeftToRight = true
    var isMenuOpened = false
    
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
    var chargerCountFlag = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LocationService.shared.authorize()
        locationManager.delegate = self
        mapView.delegate = self
        mapView.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.new, context: nil)
        startAnimate(with: "")
        existOrderView.isHidden = true
        setInitialSideMenu() // Side Menu initial Settings
        getNearByChargers() // Gettting nearby chargers to show in map
        getVehicleTypes()
        checkForOrderInService()
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
    
    //MARK: Functions
    
    func setInitialSideMenu() {
        constraintMenuLeft.constant = -constraintMenuWidth.constant
        viewBlack.alpha = 0
        viewBlack.isHidden = true
        let language = NSLocale.preferredLanguages.first!
        let direction = NSLocale.characterDirection(forLanguage: language)
        if direction == .leftToRight {
            gestureScreenEdgePan.edges = .left
            isLeftToRight = true
        } else {
            gestureScreenEdgePan.edges = .right
            isLeftToRight = false
        }
    }
    
    func getNearByChargers() {
        //let myLocatiion = CLLocationCoordinate2DMake(13.074554, 80.259644)
        let myLocation = CLLocationCoordinate2DMake(locationService.myCurrentLatitude, locationService.myCurrentLongitude)
        if checkInternetAvailablity() {
            webService.getNearByChargers(with: myLocation.latitude, and: myLocation.longitude) { (status, message, data) in
                if status == 1 {
                    let nearestChargers = data!
                    self.setLocationMarkerForChargers(chargers: nearestChargers)
                    self.stopAnimating()
                }
            }
        }
        else {
            stopAnimating()
            makeToast(message: "Your internet is weak or unavailable. Please check & try again!", time: 3.0, position: .bottom, textColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
        }
    }
    
    func getVehicleTypes() {
        if checkInternetAvailablity() {
            webService.getVehicleType { (status, message, data) in
                if status == 1 {
                    self.vehicles = data!
                    self.collectionView.reloadData()
                }
                else {
                    print(message)
                    //self.makeToast(message: message, time: 3.0, position: .bottom, textColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
                }
            }
        }
        else {
            makeToast(message: "Your internet is weak or unavailable. Please check & try again!", time: 3.0, position: .bottom, textColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
        }
    }
    
    func setLocationMarkerForChargers(chargers: [ChargerModel]) {
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
                    self.chargerId = order.chargerId
                    self.existOrderVehicleImg.downloadedFrom(link: order.vehicleImageLink)
                    self.existOrderChargerNameLbl.text = order.chargerName
                    self.existOrderRefNoLbl.text = order.vehicleName + " - " + String(order.orderId)
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

extension NearByChargersVC {
    //hamburger Menu functions
    
    func openMenu() {
        
        // when menu is opened, it's left constraint should be 0
        constraintMenuLeft.constant = 0
        
        // view for dimming effect should also be shown
        viewBlack.isHidden = false
        
        // animate opening of the menu - including opacity value
        UIView.animate(withDuration: animationDuration, animations: {
            
            self.view.layoutIfNeeded()
            self.viewBlack.alpha = self.maxBlackViewAlpha
            
        }, completion: { (complete) in
            
            // disable the screen edge pan gesture when menu is fully opened
            self.gestureScreenEdgePan.isEnabled = false
        })
    }
    
    func hideMenu() {
        
        // when menu is closed, it's left constraint should be of value that allows it to be completely hidden to the left of the screen - which is negative value of it's width
        constraintMenuLeft.constant = -constraintMenuWidth.constant
        
        // animate closing of the menu - including opacity value
        UIView.animate(withDuration: animationDuration, animations: {
            
            self.view.layoutIfNeeded()
            self.viewBlack.alpha = 0
            
        }, completion: { (complete) in
            
            // reenable the screen edge pan gesture so we can detect it next time
            self.gestureScreenEdgePan.isEnabled = true
            
            // hide the view for dimming effect so it wont interrupt touches for views underneath it
            self.viewBlack.isHidden = true
        })
    }
    
    @IBAction func gestureScreenEdgePan(_ sender: UIScreenEdgePanGestureRecognizer) {
        
        // retrieve the current state of the gesture
        if sender.state == UIGestureRecognizer.State.began {
            
            // if the user has just started dragging, make sure view for dimming effect is hidden well
            viewBlack.isHidden = false
            viewBlack.alpha = 0
            
        } else if (sender.state == UIGestureRecognizer.State.changed) {
            
            // retrieve the amount viewMenu has been dragged
            var translationX = sender.translation(in: sender.view).x
            
            if !isLeftToRight {
                translationX = -translationX
            }
            
            if -constraintMenuWidth.constant + translationX > 0 {
                
                // viewMenu fully dragged out
                constraintMenuLeft.constant = 0
                viewBlack.alpha = maxBlackViewAlpha
                
            } else if translationX < 0 {
                
                // viewMenu fully dragged in
                constraintMenuLeft.constant = -constraintMenuWidth.constant
                viewBlack.alpha = 0
                
            } else {
                
                // viewMenu is being dragged somewhere between min and max amount
                constraintMenuLeft.constant = -constraintMenuWidth.constant + translationX
                
                let ratio = translationX / constraintMenuWidth.constant
                let alphaValue = ratio * maxBlackViewAlpha
                viewBlack.alpha = alphaValue
            }
        } else {
            
            // if the menu was dragged less than half of it's width, close it. Otherwise, open it.
            if constraintMenuLeft.constant < -constraintMenuWidth.constant / 2 {
                self.hideMenu()
            } else {
                self.openMenu()
            }
        }
    }
    
    @IBAction func gesturePan(_ sender: UIPanGestureRecognizer) {
        // retrieve the current state of the gesture
        if sender.state == UIGestureRecognizer.State.began {
            
            // no need to do anything
        } else if sender.state == UIGestureRecognizer.State.changed {
            
            // retrieve the amount viewMenu has been dragged
            var translationX = sender.translation(in: sender.view).x
            
            if !isLeftToRight {
                translationX = -translationX
            }
            
            if translationX > 0 {
                
                // viewMenu fully dragged out
                constraintMenuLeft.constant = 0
                viewBlack.alpha = maxBlackViewAlpha
                
            } else if translationX < -constraintMenuWidth.constant {
                
                // viewMenu fully dragged in
                constraintMenuLeft.constant = -constraintMenuWidth.constant
                viewBlack.alpha = 0
                
            } else {
                
                // it's being dragged somewhere between min and max amount
                constraintMenuLeft.constant = translationX
                
                let ratio = (constraintMenuWidth.constant + translationX) / constraintMenuWidth.constant
                let alphaValue = ratio * maxBlackViewAlpha
                viewBlack.alpha = alphaValue
            }
        } else {
            
            // if the drag was less than half of it's width, close it. Otherwise, open it.
            if constraintMenuLeft.constant < -constraintMenuWidth.constant / 2 {
                self.hideMenu()
            } else {
                self.openMenu()
            }
        }
    }
    
    @IBAction func gestureTap(_ sender: UITapGestureRecognizer) {
        self.hideMenu()
    }
    
    @IBAction func menuBtnPressed(_ sender: Any) {
        if isMenuOpened {
            self.hideMenu()
        } else {
            self.openMenu()
        }
        isMenuOpened = !isMenuOpened
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
        let personal = webService.userDetails
        let fName = personal["firstName"]
        let lName = personal["lastName"]
        let email = personal["email"]
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
