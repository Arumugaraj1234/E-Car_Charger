//
//  OtherService.swift
//  E-CarCharger
//
//  Created by MacBook Pro on 2019-10-30.
//  Copyright © 2019 Peach. All rights reserved.
//

import UIKit

class OtherService: NSObject {
    
    private override init() {}
    static let shared = OtherService()
    
    //MARK: UserDefault Variables
    let defaults = UserDefaults.standard
    
    var isLoggedIn: Bool {
        get {
            return defaults.bool(forKey: LOGGED_IN_KEY)
        }
        set {
            defaults.set(newValue, forKey: LOGGED_IN_KEY)
        }
    }
    
    var userId: Int {
        get {
            return defaults.value(forKey: USER_ID_KEY) as! Int
        }
        set {
            defaults.set(newValue, forKey: USER_ID_KEY)
        }
    }
    
    //MARK: General Functions
    func setNaviagtionBarTitle(title: String, vC: UIViewController) {
        let x = vC.view.frame.size.width/2 - 50
        let titleLabel = UILabel(frame: CGRect(x: x, y: 0, width: 100, height: 40))
        titleLabel.text = title
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont(name: "Roboto-Regular", size: 16)
        vC.navigationItem.titleView = titleLabel
    }
}
