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
        startAnimating(CGSize(width: 125.0, height: 125.0), message: text, messageFont: UIFont(name: "AvenirNextCondensed-Demibold", size: 18), type: NVActivityIndicatorType.ballTrianglePath, color: UIColor.white, padding: 0.0, displayTimeThreshold: 1, minimumDisplayTime: 2, backgroundColor: nil, textColor: UIColor.white, fadeInAnimation: nil)
        
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
        style.backgroundColor = UIColor.clear
        style.messageColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        if let font = UIFont(name: "AvenirNextCondensed-Demibold", size: 16.0) {
            style.messageFont = font
        }
        self.view.makeToast(message, duration: time, position: position, style: style)
    }
    
    func shouldPresentLoadingViewWithText(_ show : Bool, _ title: String) {
        var fadedView: UIView?
        
        if show == true {
            fadedView = UIView(frame: CGRect(x: 0, y: 0,
                                             width: view.frame.width,
                                             height: view.frame.height))
            fadedView?.backgroundColor = UIColor.white
            fadedView?.alpha = 1.0
            fadedView?.tag = 99
            
            var bgImage = UIImageView()
            bgImage = UIImageView(frame: (fadedView?.bounds)!)
            bgImage.image = UIImage(named: "bgImage")
            bgImage.removeFromSuperview()
            
            var activityIndicator = UIActivityIndicatorView()
            activityIndicator.removeFromSuperview()
            activityIndicator = UIActivityIndicatorView(style: .white)
            activityIndicator.frame = CGRect(x: view.frame.midX - 50,
                                             y: view.frame.midY - 50 ,
                                             width: 100, height: 100)
            activityIndicator.startAnimating()
            
            view.addSubview(fadedView!)
            fadedView?.addSubview(bgImage)
            fadedView?.addSubview(activityIndicator)
            fadedView?.fadeTo(alphaValue: 1.0, withDuration: 0.2)
        } else {
            for subview in view.subviews {
                if subview.tag == 99 {
                    UIView.animate(withDuration: 0.2, animations: {
                        subview.alpha = 0.0
                    }, completion: { (finished) in
                        subview.removeFromSuperview()
                    })
                }
            }
        }
    }
    
    func checkInternetAvailablity() -> Bool {
        let status = Reach().connectionStatus()
        switch status {
        case .unknown, .offline:
            return false
        case .online(.wwan):
            return true
        case .online(.wiFi):
            return true
        }
    }
    
    
}
