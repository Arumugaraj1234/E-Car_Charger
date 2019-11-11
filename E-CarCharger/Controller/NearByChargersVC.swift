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
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: Other Outlets
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var centreMapBtn: UIButton!
    
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
    var selectedVehicleId = 0
    var vehicles = [VehicleTypeModel]()
    var selectedVehicle: VehicleTypeModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LocationService.shared.authorize()
        locationManager.delegate = self
        mapView.delegate = self
        mapView.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.new, context: nil)
        startAnimate(with: "")
        setInitialSideMenu() // Side Menu initial Settings
        getNearByChargers() // Gettting nearby chargers to show in map
        getVehicleTypes()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setNaviagtionBarTitle(title: "Nearby Chargers")
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
        let myLocatiion = CLLocationCoordinate2DMake(13.074554, 80.259644)
        if checkInternetAvailablity() {
            webService.getNearByChargers(with: myLocatiion.latitude, and: myLocatiion.longitude) { (status, message, data) in
                if status == 1 {
                    let nearestChargers = data!
                    self.setLocationMarkerForChargers(chargers: nearestChargers)
                    self.stopAnimating()
                }
            }
        }
        else {
            stopAnimating()
            makeToast(message: "Your internet is weak or unavailable. Please check & try again!", time: 3.0, position: .bottom)
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
    
    func getVehicleType() {
        let personalDetailsVc = storyboard?.instantiateViewController(withIdentifier: "PersonalDetailsVC") as! PersonalDetailsVC
        personalDetailsVc.modalPresentationStyle = .overCurrentContext
        personalDetailsVc.delegate = self
        if UIDevice.current.userInterfaceIdiom == .pad {
            personalDetailsVc.preferredContentSize = CGSize(width: 450.0, height: 750.0)
        }
        self.present(personalDetailsVc, animated: true)
        

        
    }
    
    func bookCharger() {
        let orderConfirmVc = storyboard?.instantiateViewController(withIdentifier: "OrderConfirmationPopVC") as! OrderConfirmationPopVC
        orderConfirmVc.modalPresentationStyle = .overCurrentContext
        orderConfirmVc.delegate = self
        if UIDevice.current.userInterfaceIdiom == .pad {
            orderConfirmVc.preferredContentSize = CGSize(width: 450.0, height: 750.0)
        }
        self.present(orderConfirmVc, animated: true)
    }
    
    func getVehicleTypes() {
        if checkInternetAvailablity() {
            webService.getVehicleType { (status, message, data) in
                if status == 1 {
                    self.vehicles = data!
                    self.collectionView.reloadData()
                    //self.stopAnimating()
                }
                else {
                    //self.stopAnimating()
                    self.makeToast(message: message, time: 3.0, position: .bottom)
                }
            }
        }
        else {
            //stopAnimating()
            makeToast(message: "Your internet is weak or unavailable. Please check & try again!", time: 3.0, position: .bottom)
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

extension NearByChargersVC: orderConfimationDelegate {
    func orderGotConfirmed(tag: Int) {
        if tag == 1 {
            performSegue(withIdentifier: NEARBY_CHARGERS_TO_HISTORY, sender: self)
        }
        else if tag == 2 {
            performSegue(withIdentifier: NEARBY_CHARGERS_TO_TRACK_CHARGER, sender: self)
        }
    }
}

extension NearByChargersVC: PersonalDetailsDelegate {
    func personalDetailsUpdated() {
        bookCharger()
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
           getVehicleType()
        }
        else {
            bookCharger()
        }
    }

}
