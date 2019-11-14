//
//  PersonalDetailsVC.swift
//  E-CarCharger
//
//  Created by MacBook Pro on 2019-11-09.
//  Copyright © 2019 Peach. All rights reserved.
//

import UIKit
import KOControls

protocol PersonalDetailsDelegate {
    func personalDetailsUpdated()
}
class PersonalDetailsVC: UIViewController {
    
    @IBOutlet weak var firstNameTF: KOTextField!
    @IBOutlet weak var lastNameTF: KOTextField!
    @IBOutlet weak var emailTF: KOTextField!
    @IBOutlet weak var personalDetailsView: UIView!
    
    let webService = WebRequestService.shared
    var isFirstNameValid = false
    var isLastNameValid = false
    var isEmailValid = false
    var delegate: PersonalDetailsDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        setupInitialView()
    }
    
    @IBAction func onCancelBtnPressed(sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onUpdateBtnTapped(sender: UIButton) {
        startAnimate(with: "")
        if isFirstNameValid && isLastNameValid && isEmailValid {
            if checkInternetAvailablity() {
                let personal = webService.userDetails
                let phone = personal["mobileNo"]
                let userModel = UserDetailsModel(userId: webService.userId, firstName: firstNameTF.text!, lastName: lastNameTF.text!, email: emailTF.text!, phoneNo: phone!)
                webService.updateProfile(userDetails: userModel, password: "123456") { (status, message, data) in
                    if status == 1 {
                        self.stopAnimating()
                        self.delegate?.personalDetailsUpdated()
                        self.dismiss(animated: true, completion: nil)
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
    }
    
}



extension PersonalDetailsVC: UITextFieldDelegate {
    
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
        }
        return true
    }
    
}

