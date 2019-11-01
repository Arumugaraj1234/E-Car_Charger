//
//  InstructionVC.swift
//  E-CarCharger
//
//  Created by MacBook Pro on 2019-10-30.
//  Copyright © 2019 Peach. All rights reserved.
//

import UIKit
import ValidationTextField

class InstructionVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var instructionMsgLbl: UILabel!
    @IBOutlet weak var laterBtn: UIButton!
    @IBOutlet weak var mobileView: UIView!
    @IBOutlet weak var mobileTF: ValidationTextField!
    
    //MARK: Variables
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let otherService = OtherService.shared
    var appDetails: AppDetailsModel!
    var isMobileNoValid = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDetails = appDelegate.appDetails!
        instructionMsgLbl.text = appDetails.instruction
        if appDetails.flag == 2 {
            laterBtn.isHidden = true
        }
        
        mobileTF.validCondition = { $0.count >= 10 }
        mobileTF.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        mobileTF.addHideinputAccessoryView()
        
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
    
    @objc func doneAtMobileTF(sender: UITextField) {
        mobileTF.resignFirstResponder()
//        print("abc")
//        if isMobileNoValid {
//            print("Show OTP Teft filed view")
//        }
//        else {
//            otherService.makeToast(message: "Invalid mobile number. Please check & proceed", time: 3.0, position: .bottom, vc: self)
//        }
    }

}

extension InstructionVC: UITextFieldDelegate {
    
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
        
    }
}

