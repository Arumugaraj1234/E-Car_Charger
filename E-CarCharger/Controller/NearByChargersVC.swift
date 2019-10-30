//
//  NearByChargersVC.swift
//  E-CarCharger
//
//  Created by MacBook Pro on 2019-10-30.
//  Copyright © 2019 Peach. All rights reserved.
//

import UIKit

class NearByChargersVC: UIViewController {
    
    //MARK: Outlets
    
    
    //MARK: Variables
    var otherService = OtherService.shared

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        otherService.setNaviagtionBarTitle(title: "NEARBY CHARGERS", vC: self)
    }
    
}
