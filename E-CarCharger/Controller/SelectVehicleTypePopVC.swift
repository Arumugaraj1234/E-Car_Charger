//
//  SelectVehicleTypePopVC.swift
//  E-CarCharger
//
//  Created by MacBook Pro on 2019-11-09.
//  Copyright © 2019 Peach. All rights reserved.
//

import UIKit
import ValidationTextField

protocol SelectVehicleTypeDelegate {
    func vehicleGotSelected(type: VehicleTypeModel)
}
class SelectVehicleTypePopVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var firstNameTF: ValidationTextField!
    @IBOutlet weak var lastNameTF: ValidationTextField!
    @IBOutlet weak var emailTF: ValidationTextField!
    @IBOutlet weak var personalDetailsView: UIView!
    
    var vehicles = [VehicleTypeModel]()
    var delegate: SelectVehicleTypeDelegate?
    let webService = WebRequestService.shared
    var selectedVehicle: VehicleTypeModel?
    var isFirstNameValid = false
    var isLastNameValid = false
    var isEmailValid = false

    override func viewDidLoad() {
        super.viewDidLoad()
        personalDetailsView.isHidden = true
        //hideKeyboardWhenTappedAround()
        setupInitialView()
        startAnimate(with: "")
        getVehicleTypes()
    }
    
    @IBAction func onCancelBtnPressed(sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onUpdateBtnTapped(sender: UIButton) {
        if isFirstNameValid && isLastNameValid && isEmailValid {
            let personal = webService.userDetails
            let phone = personal["mobileNo"]
            var userDetails = [String:String]()
            userDetails["firstName"] = firstNameTF.text!
            userDetails["lastName"] = lastNameTF.text!
            userDetails["email"] = emailTF.text!
            userDetails["mobileNo"] = phone!
            webService.userDetails = userDetails
            if let vehicle = selectedVehicle {
                delegate?.vehicleGotSelected(type: vehicle)
                dismiss(animated: true, completion: nil)
            }
            
        }

    }
    
    func setupInitialView() {
        emailTF.validCondition = {
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
            
            let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
            return emailTest.evaluate(with: $0)
        }
        emailTF.titleFont = UIFont(name: "Georgia", size: 14.0)!
        emailTF.errorFont = UIFont(name: "Georgia", size: 16.0)!
        emailTF.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        
        firstNameTF.validCondition = {$0.count > 0}
        firstNameTF.titleFont = UIFont(name: "Georgia", size: 14.0)!
        firstNameTF.errorFont = UIFont(name: "Georgia", size: 16.0)!
        firstNameTF.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        
        lastNameTF.validCondition = {$0.count > 0}
        lastNameTF.titleFont = UIFont(name: "Georgia", size: 14.0)!
        lastNameTF.errorFont = UIFont(name: "Georgia", size: 16.0)!
        lastNameTF.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        
    }
    
    func getVehicleTypes() {
        if checkInternetAvailablity() {
            webService.getVehicleType { (status, message, data) in
                if status == 1 {
                    self.vehicles = data!
                    self.tableView.reloadData()
                    self.stopAnimating()
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
    
    
}

extension SelectVehicleTypePopVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vehicles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "VehicleTypeCell", for: indexPath) as? VehicleTypeCell else {return UITableViewCell()}
        let vehicleType = vehicles[indexPath.row]
        cell.configureCell(vehicle: vehicleType)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedVehicleType = vehicles[indexPath.row]
        self.selectedVehicle = selectedVehicleType
        let personal = webService.userDetails
        let fName = personal["firstName"]
        let lName = personal["lastName"]
        let email = personal["email"]
        if fName == "" || lName == "" || email == "" {
            personalDetailsView.isHidden = false
        }
        else {
            delegate?.vehicleGotSelected(type: selectedVehicleType)
            dismiss(animated: true, completion: nil)
        }
    }
}

extension SelectVehicleTypePopVC: UITextFieldDelegate {
    
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
            firstNameTF.resignFirstResponder()
            lastNameTF.becomeFirstResponder()
        }
        else if textField.tag == 2 {
            lastNameTF.resignFirstResponder()
            emailTF.becomeFirstResponder()
        }
        else if textField.tag == 3 {
            emailTF.resignFirstResponder()
        }
        return true
    }
    
}

