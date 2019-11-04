//
//  RoundedBtn.swift
//  E-CarCharger
//
//  Created by MacBook Pro on 2019-11-04.
//  Copyright © 2019 Peach. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedBtn: UIButton {
    
    @IBInspectable var cornerRadius:CGFloat = 10.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    override func awakeFromNib() {
        setupView()
    }
    
    func setupView(){
        self.layer.cornerRadius = cornerRadius
        
        self.layer.shadowColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.3)
        self.layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 5.0
        self.layer.masksToBounds = false
    }
    
}
