//
//  ChargerModel.swift
//  E-CarCharger
//
//  Created by MacBook Pro on 2019-11-08.
//  Copyright © 2019 Peach. All rights reserved.
//

import UIKit

class ChargerModel {
    let id: Int
    let firstName: String
    let lastName: String
    let email: String
    let phone: String
    let status: Int
    let flag: Int
    let totalChargedCount: Int
    let currentLatitude: Double
    let currentLongitude: Double
    
    init(id: Int, firstName: String, lastName: String, email: String, phone: String, status: Int, flag: Int, totalChargedCount: Int, currentLatitude: Double, currentLongitude: Double) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phone = phone
        self.status = status
        self.flag = flag
        self.totalChargedCount = totalChargedCount
        self.currentLatitude = currentLatitude
        self.currentLongitude = currentLongitude
    }
    
}
