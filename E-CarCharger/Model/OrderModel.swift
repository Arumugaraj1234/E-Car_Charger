//
//  OrderModel.swift
//  E-CarCharger
//
//  Created by MacBook Pro on 2019-11-18.
//  Copyright © 2019 Peach. All rights reserved.
//

import Foundation

class OrderModel {
    var orderId: Int
    var vehicleName: String
    var vehicleImageLink: String
    var chargerName: String
    var fare: Double
    var latitude: Double
    var longitude: Double
    var otp: Int
    var bookedTime: String
    var paymentStatus: String
    var status: String
    
    init(orderId: Int, vehicleName: String, vehicleImageLink: String, chargerName: String, fare: Double, latitude: Double, longitude: Double, otp: Int, bookedTime: String, paymentStatus: String, status: String) {
        self.orderId = orderId
        self.vehicleName = vehicleName
        self.vehicleImageLink = vehicleImageLink
        self.chargerName = chargerName
        self.fare = fare
        self.latitude = latitude
        self.longitude = longitude
        self.otp = otp
        self.bookedTime = bookedTime
        self.paymentStatus = paymentStatus
        self.status = status
    }
}
