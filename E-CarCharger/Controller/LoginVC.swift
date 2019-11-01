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
    @IBOutlet weak var sendOtpBtn: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        initialSetUp()
        
        mobileNoTF.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        otpTF.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        
    }
    
    @IBAction func onLoginBtnPressed(sender: UIButton) {
        //Will do after login completed
    }
    
    @IBAction func onSendOtpBtnPressed(sender: UIButton) {
        //If it got successfully send Otp
        view.endEditing(true)
        sendOtpBtn.setTitle("RESEND OTP", for: .normal)
        loginBtn.isHidden = false
        makeToast(message: "OTP sent to your phone. Please use that for login", time: 3.0, position: .bottom)
    }
    
    func initialSetUp() {
        containerView.layer.cornerRadius = 15.0
        
        bgImage.layer.cornerRadius = 15.0
        bgImage.clipsToBounds = true
        
        mobileNoTF.validCondition = { $0.count >= 10 }
        //mobileNoTF.addHideinputAccessoryView()
        
        otpTF.validCondition = { $0.count == 6 }
        //otpTF.addHideinputAccessoryView()
        
        loginBtn.isHidden = true
        setLoginBtnEnableStatus(as: false)
        
        setOtpBtnEnableStatus(as: false)
    }
    
    func makeToast(message: String, time: TimeInterval, position: ToastPosition) {
        var style = ToastStyle()
        style.backgroundColor = #colorLiteral(red: 1, green: 0.9843137255, blue: 0.649359809, alpha: 1)
        style.messageColor = #colorLiteral(red: 0.5803921569, green: 0.09019607843, blue: 0.3176470588, alpha: 1)
        self.view.makeToast(message, duration: time, position: position, style: style)
    }
    
    func setLoginBtnEnableStatus (as enable: Bool) {
        if enable {
            loginBtn.isEnabled = true
            loginBtn.backgroundColor = #colorLiteral(red: 0.5803921569, green: 0.09019607843, blue: 0.3176470588, alpha: 1)
            loginBtn.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
        }
        else {
            loginBtn.isEnabled = false
            loginBtn.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
            loginBtn.setTitleColor(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), for: .normal)
        }
    }
    
    func setOtpBtnEnableStatus (as enable: Bool) {
        if enable {
            sendOtpBtn.isEnabled = true
            sendOtpBtn.backgroundColor = #colorLiteral(red: 0.5803921569, green: 0.09019607843, blue: 0.3176470588, alpha: 1)
            sendOtpBtn.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
        }
        else {
            sendOtpBtn.isEnabled = false
            sendOtpBtn.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
            sendOtpBtn.setTitleColor(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), for: .normal)
        }
    }
    

    
}

extension LoginVC: UITextFieldDelegate {
    
    @objc func textFieldDidChange(textField: UITextField) {
        
        if textField.tag == 1 {
            if textField.text != "" {
                if (textField.text?.count)! >= 10 {
                    setOtpBtnEnableStatus(as: true)
                }
                else {
                    setOtpBtnEnableStatus(as: false)
                }
            }
            else {
                setOtpBtnEnableStatus(as: false)
            }
        }
        
        if textField.tag == 2 {
            if textField.text != "" {
                if (textField.text?.count)! == 6 {
                    setLoginBtnEnableStatus(as: true)
                }
                else {
                    setLoginBtnEnableStatus(as: false)
                }
            } else {
                setLoginBtnEnableStatus(as: false)
            }
        }
        
    }
    
}


