//
//  TextFiledExt.swift
//  E-CarCharger
//
//  Created by MacBook Pro on 2019-11-01.
//  Copyright © 2019 Peach. All rights reserved.
//

import UIKit

extension UITextField {
    
    func addHideinputAccessoryView() {
        
        let toolBar = UIToolbar()
        
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.black
        toolBar.barTintColor = #colorLiteral(red: 0.8078431373, green: 0.8, blue: 0.8274509804, alpha: 1)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "DONE", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.resignFirstResponder))
        doneButton.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Roboto-Medium", size: 16)!], for: UIControl.State.normal)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([ spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        self.inputAccessoryView = toolBar
    }
}
