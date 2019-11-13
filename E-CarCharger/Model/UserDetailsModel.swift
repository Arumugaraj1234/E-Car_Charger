//
//  UserDetailsModel.swift
//  E-CarCharger
//
//  Created by MacBook Pro on 2019-11-13.
//  Copyright © 2019 Peach. All rights reserved.
//

import Foundation

class UserDetailsModel {
    var userId: Int
    var firstName: String
    var lastName: String
    var email: String
    var phoneNo: String
    
    init(userId: Int, firstName: String, lastName: String, email: String, phoneNo: String) {
        self.userId = userId
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phoneNo = phoneNo
    }
}
