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
        toolBar.tintColor = UIColor.white
        toolBar.barTintColor = #colorLiteral(red: 0.5808190107, green: 0.0884276256, blue: 0.3186392188, alpha: 1)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "DONE", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.resignFirstResponder))
        doneButton.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "AvenirNextCondensed-Demibold", size: 18)!], for: UIControl.State.normal)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([ spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        self.inputAccessoryView = toolBar
    }
}
