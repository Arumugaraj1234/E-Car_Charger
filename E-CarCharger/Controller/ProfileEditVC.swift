//
//  ProfileEditVC.swift
//  E-CarCharger
//
//  Created by MacBook Pro on 2019-11-15.
//  Copyright © 2019 Peach. All rights reserved.
//

import UIKit
import KOControls

class ProfileEditVC: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var firstNameTF: KOTextField!
    @IBOutlet weak var lastNameTF: KOTextField!
    @IBOutlet weak var emailTF: KOTextField!
    @IBOutlet weak var phoneNoTF: KOTextField!
    @IBOutlet weak var verifyOtpView: UIView!
    
    //MARK: VARIABLES
    var isFirstNameValid = false
    var isLastNameValid = false
    var isEmailValid = false
    var isPhoneValid = false
    let webService = WebRequestService.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        
        verifyOtpView.isHidden = true
        setupInitialView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setNaviagtionBarTitle(title: "Edit Profile")
    }
    
    @IBAction func onBackBtnPressed(sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onUpdateBtnPressed(sender: UIButton) {
        view.endEditing(true)
        validateTextField()
        startAnimate(with: "")
        if isFirstNameValid && isLastNameValid && isEmailValid && isPhoneValid {
            if checkInternetAvailablity() {
                let userModel = UserDetailsModel(userId: webService.userId, firstName: firstNameTF.text!, lastName: lastNameTF.text!, email: emailTF.text!, phoneNo: phoneNoTF.text!)
                webService.updateProfile(userDetails: userModel, password: "123456") { (status, message, data) in
                    if status == 1 {
                        self.stopAnimating()
                        self.dismiss(animated: true, completion: nil)
                    }
                    else if status == 2 {
                        self.stopAnimating()
                        UIView.animate(withDuration: 3.0, animations: {
                            self.verifyOtpView.isHidden = false
                        })
                    }
                    else {
                        self.stopAnimating()
                        self.makeToast(message: message, time: 3.0, position: .bottom)
                    }
                }
            }
            else {
                stopAnimating()
                makeToast(message: "Your internet is weak or unavailable. Please check & try again!", time: 3.0, position: .bottom)
            }
        }
        else {
            stopAnimating()
            makeToast(message: "Please provide the valid details to update!", time: 3.0, position: .bottom)
        }
    }
    
    func setupInitialView() {
        
        let userDetails = webService.userDetails
        let fName = userDetails["firstName"] ?? ""
        let lName = userDetails["lastName"] ?? ""
        let email = userDetails["email"] ?? ""
        let phone = userDetails["mobileNo"] ?? ""
        
        firstNameTF.text = fName
        lastNameTF.text = lName
        emailTF.text = email
        phoneNoTF.text = phone
        
        firstNameTF.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        firstNameTF.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0)
        firstNameTF.errorInfo.description = "Invalid First Name"
        firstNameTF.validation.add(validator: KOFunctionTextValidator(function: { fName -> Bool in
            return fName.count > 0
        }))
        
        lastNameTF.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        lastNameTF.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0)
        lastNameTF.errorInfo.description = "Invalid Last Name"
        lastNameTF.validation.add(validator: KOFunctionTextValidator(function: { lName -> Bool in
            return lName.count > 0
        }))
        
        emailTF.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        emailTF.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0)
        emailTF.errorInfo.description = "Invalid Email Address"
        emailTF.validation.add(validator: KORegexTextValidator.mailValidator)
        
        phoneNoTF.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        phoneNoTF.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0)
        phoneNoTF.addHideinputAccessoryView()
        phoneNoTF.errorInfo.description = "Invalid Mobile Number"
        phoneNoTF.validation.add(validator: KOFunctionTextValidator(function: { mobile -> Bool in
            return mobile.count >= 10 && mobile.count <= 13
        }))
    }
    
    func validateTextField() {
        if firstNameTF.text != "" {
            isFirstNameValid = true
        }
        else {
            isFirstNameValid = false
        }
        
        if lastNameTF.text != "" {
            isLastNameValid = true
        }
        else {
            isLastNameValid = false
        }
        
        if emailTF.text != "" {
            if isValidEmail(testStr: emailTF.text!) {
                isEmailValid = true
            }
            else {
                isEmailValid = false
            }
        }
        else {
            isEmailValid = false
        }
        
        if phoneNoTF.text != "" {
            if (phoneNoTF.text?.count)! >= 10 && (phoneNoTF.text?.count)! <= 13 {
                isPhoneValid = true
            }
            else {
                isPhoneValid = false
            }
        }
        else {
            isPhoneValid = false
        }
    }


}

extension ProfileEditVC: UITextFieldDelegate {
    
    @objc func textFieldDidChange(textField: UITextField) {
        
        if textField.tag == 1 {
            if textField.text != "" {
                isFirstNameValid = true
            }
            else {
                isFirstNameValid = false
            }
        }
        
        if textField.tag == 2 {
            if textField.text != "" {
                isLastNameValid = true
            }
            else {
                isLastNameValid = false
            }
        }
        
        if textField.tag == 3 {
            if textField.text != "" {
                if isValidEmail(testStr: textField.text!) {
                    isEmailValid = true
                }
                else {
                    isEmailValid = false
                }
            }
            else {
                isEmailValid = false
            }
        }
        
        if textField.tag == 4 {
            if textField.text != "" {
                if (textField.text?.count)! >= 10 {
                    isPhoneValid = true
                }
                else {
                    isPhoneValid = false
                }
            }
            else {
                isPhoneValid = false
            }
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 1 {
            let _ = firstNameTF.resignFirstResponder()
            let _ = lastNameTF.becomeFirstResponder()
        }
        else if textField.tag == 2 {
            let _ = lastNameTF.resignFirstResponder()
            let _ = emailTF.becomeFirstResponder()
        }
        else if textField.tag == 3 {
            let _ = emailTF.resignFirstResponder()
            let _ = phoneNoTF.becomeFirstResponder()
        }
        else if textField.tag == 4 {
            let _ = phoneNoTF.resignFirstResponder()
        }
        return true
    }
    
}
