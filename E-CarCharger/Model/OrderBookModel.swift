//
//  OrderBookModel.swift
//  E-CarCharger
//
//  Created by MacBook Pro on 2019-11-13.
//  Copyright © 2019 Peach. All rights reserved.
//

import Foundation

class OrderBookModel {
    var id: Int
    var vehicleId: Int
    
    init(id: Int, vehicleId: Int) {
        self.id = id
        self.vehicleId = vehicleId
    }
    
}
