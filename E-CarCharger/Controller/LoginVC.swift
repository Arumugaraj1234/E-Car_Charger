//
//  LoginVC.swift
//  E-CarCharger
//
//  Created by MacBook Pro on 2019-10-31.
//  Copyright © 2019 Peach. All rights reserved.
//

import UIKit
import ValidationTextField
import Toast_Swift

class LoginVC: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var mobileNoTF: ValidationTextField!
    @IBOutlet weak var otpTF: ValidationTextField!
    @IBOutlet weak var loginBtn: UIButton!
    
    var isOtpSent = false

    override func viewDidLoad() {
        super.viewDidLoad()

        initialSetUp()
    }
    
    @IBAction func onLoginBtnPressed(sender: UIButton) {
        if isOtpSent == true {
            loginBtn.setTitle("SEND OTP", for: .normal)
            mobileNoTF.isHidden = false
            otpTF.isHidden = true
            makeToast(message: "Oops! Invalid OTP. Please check", time: 3.0, position: .bottom)
        }
        else {
            loginBtn.setTitle("LOGIN", for: .normal)
            mobileNoTF.isHidden = true
            otpTF.isHidden = false
            makeToast(message: "OTP sent to mobile. Please use that for login", time: 3.0, position: .bottom)
        }
        isOtpSent = !isOtpSent
    }
    
    func initialSetUp() {
        containerView.layer.cornerRadius = 15.0
        bgImage.layer.cornerRadius = 15.0
        bgImage.clipsToBounds = true
        otpTF.isHidden = true
        mobileNoTF.isHidden = false
        loginBtn.setTitle("SEND OTP", for: .normal)
        mobileNoTF.validCondition = { $0.count >= 10 }
        otpTF.validCondition = { $0.count == 6 }
    }
    
    func makeToast(message: String, time: TimeInterval, position: ToastPosition) {
        var style = ToastStyle()
        style.backgroundColor = #colorLiteral(red: 1, green: 0.4885113936, blue: 0.3505289849, alpha: 1)
        style.messageColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.view.makeToast(message, duration: time, position: position, style: style)
    }
    

}
