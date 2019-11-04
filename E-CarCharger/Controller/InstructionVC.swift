//
//  InstructionVC.swift
//  E-CarCharger
//
//  Created by MacBook Pro on 2019-10-30.
//  Copyright © 2019 Peach. All rights reserved.
//

import UIKit
import ValidationTextField
import Toast_Swift
import NVActivityIndicatorView

class InstructionVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var instructionMsgLbl: UILabel!
    @IBOutlet weak var laterBtn: UIButton!
    @IBOutlet weak var mobileView: UIView!
    @IBOutlet weak var mobileTF: ValidationTextField!
    @IBOutlet weak var otpView: UIView!
    @IBOutlet weak var otpTF: ValidationTextField!
    @IBOutlet weak var otpStackViewConstraint: NSLayoutConstraint!
    
    //MARK: Variables
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let otherService = OtherService.shared
    var appDetails: AppDetailsModel!
    var isMobileNoValid = false
    var isOtpValid = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDetails = appDelegate.appDetails!
        instructionMsgLbl.text = appDetails.instruction
        hideKeyboardWhenTappedAround()
        
        mobileTF.validCondition = { $0.count >= 10 }
        mobileTF.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        mobileTF.addHideinputAccessoryView()
        mobileTF.titleFont = UIFont(name: "Georgia", size: 14.0)!
        mobileTF.errorFont = UIFont(name: "Georgia", size: 16.0)!
        
        otpTF.titleFont = UIFont(name: "Georgia", size: 14.0)!
        otpTF.errorFont = UIFont(name: "Georgia", size: 16.0)!
        otpTF.validCondition = { $0.count == 6 }
        otpTF.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        otpTF.addHideinputAccessoryView()
        
        if appDetails.flag == 2 {
            mobileView.isHidden = true
            otpView.isHidden = true
            laterBtn.isHidden = true
        }
        else if appDetails.flag == 1 {
            mobileView.isHidden = true
            otpView.isHidden = true
        }
        else {
            otpView.isHidden = true
        }
        
    }
    
    @IBAction func onBtnTapped(sender: UIButton) {
        
        if sender.tag == 1 {
            appDelegate.skipToNearByChargersScreen()
        }
        else if sender.tag == 2 {
            //Redirect to AppStore, Once got the appstore link
            print("Redirected to App Store")
        }
        
    }
    
    @IBAction func onSendOtpBtnTapped(sender: UIButton) {
        view.endEditing(true)
        if isMobileNoValid {
            otpView.isHidden = false
        }
        else {
            makeToast(message: "Oops! Invalid mobile number. Please check.", time: 3.0, position: .bottom)
        }
    }
    
    @IBAction func onResendOtpBtnTapped(sender: UIButton) {
        
    }
    
    @IBAction func onChangePhoneNoBtnTapped(sender: UIButton) {
        otpView.isHidden = true
    }
    
    @IBAction func onLoginBtnTapped(sender: UIButton) {
        view.endEditing(true)
        if isOtpValid {
            otherService.isLoggedIn = true
            appDelegate.skipToNearByChargersScreen()
        }
        else {
            makeToast(message: "Oops! Invalid otp entered.", time: 3.0, position: .bottom)
        }
    }

}

extension InstructionVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 2 {
            otpStackViewConstraint.constant = -50.0
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 2 {
            otpStackViewConstraint.constant = 0
        }
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        
        if textField.tag == 1 {
            if textField.text != "" {
                if (textField.text?.count)! >= 10 {
                    isMobileNoValid = true
                }
                else {
                    isMobileNoValid = false
                }
            }
            else {
                isMobileNoValid = false
            }
        }
        
        if textField.tag == 2 {
            if textField.text != "" {
                if (textField.text?.count)! == 6 {
                    isOtpValid = true
                }
                else {
                    isOtpValid = false
                }
            }
            else {
                isOtpValid = false
            }
        }
        
    }
}

