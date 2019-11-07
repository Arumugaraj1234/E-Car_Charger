//
//  AppDelegate.swift
//  E-CarCharger
//
//  Created by MacBook Pro on 2019-10-30.
//  Copyright © 2019 Peach. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let locationService = LocationService.shared


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        locationService.setGoogleApiKeys()
        locationService.authorize()
        return true
    }
    
    func skipToNearByChargersScreen(){
        let sb = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = sb.instantiateViewController(withIdentifier: "NearByChargersNavigation") as! UINavigationController
        
        vc.modalTransitionStyle = .crossDissolve
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
    }
    
}

