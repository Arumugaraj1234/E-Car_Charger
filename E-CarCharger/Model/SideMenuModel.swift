//
//  SideMenuModel.swift
//  E-CarCharger
//
//  Created by MacBook Pro on 2019-11-05.
//  Copyright © 2019 Peach. All rights reserved.
//

import UIKit

class SideMenuModel {
    
    var menuName: String
    var whiteMenuIcon: UIImage
    var blueMenuIcon: UIImage
    
    init(menuName: String, whiteMenuIcon: UIImage, blueMenuIcon: UIImage) {
        self.menuName = menuName
        self.whiteMenuIcon = whiteMenuIcon
        self.blueMenuIcon = blueMenuIcon
    }
}
