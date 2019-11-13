//
//  OrderModel.swift
//  E-CarCharger
//
//  Created by MacBook Pro on 2019-11-13.
//  Copyright © 2019 Peach. All rights reserved.
//

import Foundation

class OrderModel {
    var id: Int
    var vehicleId: Int
    var chargerId: Int
    var fare: Double
    var chargerLatitude: Double
    var chargerLongitude: Double
    var chargerStatus: Int
    var otp: Int
    var bookedTime: String
    var paymentStatus: Int
    var paymentType: Int
    var transactionId: String
    var declinedIds: String
    
    init(id: Int, vehicleId: Int, chargerId: Int, fare: Double, chargerLatitude: Double, chargerLongitude: Double, chargerStatus: Int, otp: Int, bookedTime: String, paymentStatus: Int, paymentType: Int, transactionId: String, declinedIds: String) {
        self.id = id
        self.vehicleId = vehicleId
        self.chargerId = chargerId
        self.fare = fare
        self.chargerLatitude = chargerLatitude
        self.chargerLongitude = chargerLongitude
        self.chargerStatus = chargerStatus
        self.otp = otp
        self.bookedTime = bookedTime
        self.paymentStatus = paymentStatus
        self.paymentType = paymentType
        self.transactionId = transactionId
        self.declinedIds = declinedIds
    }
    
}
