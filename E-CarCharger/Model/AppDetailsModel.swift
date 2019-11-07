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
    var recentVersion: Double
    var instruction: String
    
    init(flag: Int,recentVersion: Double, instruction: String) {
        self.flag = flag
        self.recentVersion = recentVersion
        self.instruction = instruction
    }
    
}
