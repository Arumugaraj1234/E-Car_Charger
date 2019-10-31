//
//  RoundedTF.swift
//  E-CarCharger
//
//  Created by MacBook Pro on 2019-10-31.
//  Copyright © 2019 Peach. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedTF: UITextField {
    
    @IBInspectable var cornerRadius:CGFloat = 5.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    let padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10);
    
    override func awakeFromNib() {
        setupView()
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        //return UIEdgeInsetsInsetRect(bounds, padding)
        
        return bounds.inset(by: padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    func setupView() {
        self.layer.cornerRadius = cornerRadius
    }
    
}
