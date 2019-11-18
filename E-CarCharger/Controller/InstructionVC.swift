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
import KOControls

class InstructionVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var instructionMsgLbl: UILabel!
    @IBOutlet weak var laterBtn: UIButton!
    @IBOutlet weak var mobileView: UIView!
    @IBOutlet weak var mobileTF: KOTextField!
    @IBOutlet weak var otpView: UIView!
    @IBOutlet weak var otpTF: KOTextField!
    @IBOutlet weak var otpStackViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var updateBtnStackView: UIStackView!
    @IBOutlet weak var mobileErrorLbl: UILabel!
    
    //MARK: Variables
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let webService = WebRequestService.shared
    var appDetails: AppDetailsModel?
    var isMobileNoValid = false
    var isOtpValid = false
    var isOldVersion: Bool?

    override func viewDidLoad() {
        super.viewDidLoad()
        shouldPresentLoadingViewWithText(true, "")
        //<wpt lat="13.074554" lon="80.259644"> 
        setUpInitialView()
        //instructionMsgLbl.attributedText = htmlText.htmlToAttributedString
        
        hideKeyboardWhenTappedAround()
        
        getAppDetails()
        
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
        startAnimate(with: "")
        if isMobileNoValid {
            sendOtp()
        }
        else {
            stopAnimating()
            makeToast(message: "Oops! Invalid mobile number. Please check.", time: 3.0, position: .bottom)
        }
    }
    
    @IBAction func onResendOtpBtnTapped(sender: UIButton) {
        
    }
    
    @IBAction func onChangePhoneNoBtnTapped(sender: UIButton) {
        UIView.animate(withDuration: 2.0) {
            self.otpView.isHidden = true
        }
    }
    
    @IBAction func onLoginBtnTapped(sender: UIButton) {
        view.endEditing(true)
        startAnimating()
        if isOtpValid {
            checkOtp()
        }
        else {
            stopAnimating()
            makeToast(message: "Oops! Invalid otp entered.", time: 3.0, position: .bottom)
        }
    }
    
    func setUpInitialView() {
        mobileTF.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        mobileTF.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0)
        mobileTF.addHideinputAccessoryView()
        mobileTF.errorInfo.description = "Invalid Mobile Number"
        mobileTF.validation.add(validator: KOFunctionTextValidator(function: { mobile -> Bool in
            return mobile.count >= 10 && mobile.count <= 13
        }))

        otpTF.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        otpTF.addHideinputAccessoryView()
        otpTF.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0)
        otpTF.errorInfo.description = "Invalid Otp"
        otpTF.validation.add(validator: KOFunctionTextValidator(function: { otp -> Bool in
            return otp.count == 6
        }))
        
        
    }
    
    func getAppDetails(){
        if checkInternetAvailablity() {
            webService.getAppInitDetails { (status, message, result) in
                if status == 1 {
                    self.appDetails = result!
                    let appVersionInMyMachine = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
                    if appVersionInMyMachine! != "\(result!.recentVersion)" {
                        self.isOldVersion = true
                    }
                    self.shouldPresentLoadingViewWithText(false, "")
                    if result!.flag == 2 && self.isOldVersion == true {
                        self.mobileView.isHidden = true
                        self.otpView.isHidden = true
                        self.laterBtn.isHidden = true
                        self.instructionMsgLbl.attributedText = result!.instruction.htmlToAttributedString
                        self.instructionMsgLbl.textAlignment = .center
                    }
                    else if result!.flag == 1 && self.isOldVersion == true {
                        self.mobileView.isHidden = true
                        self.otpView.isHidden = true
                        self.instructionMsgLbl.attributedText = result!.instruction.htmlToAttributedString
                        self.instructionMsgLbl.textAlignment = .center
                    }
                    else if result!.flag == 3 {
                        self.mobileView.isHidden = true
                        self.otpView.isHidden = true
                        self.instructionMsgLbl.attributedText = result!.instruction.htmlToAttributedString
                        self.instructionMsgLbl.textAlignment = .center
                        self.updateBtnStackView.isHidden = true
                    }
                    else {
                        if self.webService.isLoggedIn {
                            self.appDelegate.skipToNearByChargersScreen()
                        }
                        else {
                            self.otpView.isHidden = true
                        }
                    }
                }
                else {
                    self.shouldPresentLoadingViewWithText(false, "")
                    self.mobileView.isHidden = true
                    self.otpView.isHidden = true
                    self.instructionMsgLbl.text = "Something went wrong. Please try again later."
                    self.instructionMsgLbl.textAlignment = .center
                    self.updateBtnStackView.isHidden = true
                }
            }
        }
        else {
            self.shouldPresentLoadingViewWithText(false, "")
            self.mobileView.isHidden = true
            self.otpView.isHidden = true
            self.instructionMsgLbl.text = "Your internet is weak or unavailable. Please check & try again!"
            self.instructionMsgLbl.textAlignment = .center
            self.updateBtnStackView.isHidden = true
        }
        
    }
    
    func sendOtp() {
        if checkInternetAvailablity() {
            webService.sendOtpForLogin(with: mobileTF.text!) { (status, message) in
                self.stopAnimating()
                if status == 1 {
                    UIView.animate(withDuration: 2.0, animations: {
                        self.otpView.isHidden = false
                    })
                }
                else {
                    self.makeToast(message: message, time: 3.0, position: .bottom)
                }
            }
        }
        else {
            stopAnimating()
            makeToast(message: "Your internet is weak or unavailable. Please check & try again!", time: 3.0, position: .bottom)
        }
    }
    
    func checkOtp() {
        if checkInternetAvailablity() {
            webService.checkOtpForLogin(with: mobileTF.text!, with: otpTF.text!) { (status, message) in
                self.stopAnimating()
                if status == 1 {
                    self.appDelegate.skipToNearByChargersScreen()
                }
                else {
                    self.makeToast(message: message, time: 3.0, position: .bottom)
                }
            }
        }
        else {
            stopAnimating()
            makeToast(message: "Your internet is weak or unavailable. Please check & try again!", time: 3.0, position: .bottom)
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

