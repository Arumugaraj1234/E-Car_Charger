//
//  VehicleTypeModel.swift
//  E-CarCharger
//
//  Created by MacBook Pro on 2019-11-09.
//  Copyright © 2019 Peach. All rights reserved.
//

import Foundation

class VehicleTypeModel {
    var id: Int
    var name: String
    var flag: Int
    var imageLink: String
    
    init(id: Int, name: String, flag: Int, imageLink: String) {
        self.id = id
        self.name = name
        self.flag = flag
        self.imageLink = imageLink
    }
}
