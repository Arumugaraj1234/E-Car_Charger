//
//  InstructionVC.swift
//  E-CarCharger
//
//  Created by MacBook Pro on 2019-10-30.
//  Copyright © 2019 Peach. All rights reserved.
//

import UIKit

class InstructionVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var instructionMsgLbl: UILabel!
    @IBOutlet weak var laterBtn: UIButton!
    
    //MARK: Variables
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var appDetails: AppDetailsModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDetails = appDelegate.appDetails!
        instructionMsgLbl.text = appDetails.instruction
        if appDetails.flag == 2 {
            laterBtn.isHidden = true
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

}

