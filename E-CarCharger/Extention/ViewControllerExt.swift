//
//  ViewControllerExt.swift
//  E-CarCharger
//
//  Created by MacBook Pro on 2019-11-04.
//  Copyright © 2019 Peach. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Toast_Swift

extension UIViewController: NVActivityIndicatorViewable {
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func startAnimate(with text: String){
        startAnimating(CGSize(width: 75.0, height: 75.0), message: text, messageFont: UIFont(name: "AvenirNextCondensed-Demibold", size: 18), type: NVActivityIndicatorType.ballScaleMultiple, color: UIColor.white, padding: 0.0, displayTimeThreshold: 1, minimumDisplayTime: 2, backgroundColor: nil, textColor: UIColor.white, fadeInAnimation: nil)
        
    }
    
    //MARK: General Functions
    func setNaviagtionBarTitle(title: String) {
        let x = self.view.frame.size.width/2 - 50
        let titleLabel = UILabel(frame: CGRect(x: x, y: 0, width: 100, height: 40))
        titleLabel.text = title
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont(name: "Georgia", size: 16)
        self.navigationItem.titleView = titleLabel
    }
    
    func makeToast(message: String, time: TimeInterval, position: ToastPosition) {
        var style = ToastStyle()
        style.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 0.5)
        style.messageColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
        self.view.makeToast(message, duration: time, position: position, style: style)
    }
    
    
    
    
}
