//
//  AppDetailsModel.swift
//  E-CarCharger
//
//  Created by MacBook Pro on 2019-10-30.
//  Copyright © 2019 Peach. All rights reserved.
//

import Foundation

class AppDetailsModel {
    
    var flag: Int
    var instruction: String
    var isOldVersion: Bool
    
    init(flag: Int, instruction: String, isOldVersion: Bool) {
        self.flag = flag
        self.instruction = instruction
        self.isOldVersion = isOldVersion
    }
}
