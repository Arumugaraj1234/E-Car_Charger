//
//  CompletedOrderModel.swift
//  E-CarCharger
//
//  Created by MacBook Pro on 2019-12-24.
//  Copyright © 2019 Peach. All rights reserved.
//

import Foundation

class CompletedOrderModel {
    var orderStatus: Int
    var timeTookToCharge: String
    var totalFare: String
    
    init(orderStatus: Int, timeTookToCharge: String, totalFare: String) {
        self.orderStatus = orderStatus
        self.timeTookToCharge = timeTookToCharge
        self.totalFare = totalFare
    }
}
