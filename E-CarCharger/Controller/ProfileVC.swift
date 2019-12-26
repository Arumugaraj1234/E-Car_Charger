//
//  ProfileVC.swift
//  E-CarCharger
//
//  Created by MacBook Pro on 2019-11-15.
//  Copyright © 2019 Peach. All rights reserved.
//

import UIKit
import SideMenu

class ProfileVC: UIViewController {
    
    //MARK: OUTLETS
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var firstNameLbl: UILabel!
    @IBOutlet weak var lastNameLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var phoneLbl: UILabel!
    @IBOutlet weak var detailsView: UIView!
    
    //MARK: VARIABLES
    let webService = WebRequestService.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        startAnimate(with: "")
        setupView()
        setInitialValues()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setNaviagtionBarTitle(title: "Profile")
    }
    
    @IBAction func onBackBtnPressed(_ sender: UIBarButtonItem) {
        let menu = storyboard!.instantiateViewController(withIdentifier: "SideMenu") as! UISideMenuNavigationController
        menu.sideMenuManager.menuPresentMode = .menuDissolveIn
        present(menu, animated: true, completion: nil)
        
//        let main:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let upcomingOrdersVC = main.instantiateViewController(withIdentifier: "NearByChargersNavigation") as! UINavigationController
//        present(upcomingOrdersVC, animated: true, completion: nil)
    }
    
    @IBAction func onEditProfileBtnPressed(sender: UIButton) {
        performSegue(withIdentifier: PROFILEVC_TO_EDIT_PROFILEVC, sender: self)
    }
    
    func setupView() {
        firstNameLbl.layer.cornerRadius = 5.0
        firstNameLbl.layer.masksToBounds = true
        lastNameLbl.layer.cornerRadius = 5.0
        lastNameLbl.layer.masksToBounds = true
        emailLbl.layer.cornerRadius = 5.0
        emailLbl.layer.masksToBounds = true
        phoneLbl.layer.cornerRadius = 5.0
        phoneLbl.layer.masksToBounds = true
        
//        detailsView.layer.borderWidth = 1.0
//        detailsView.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
//        detailsView.layer.cornerRadius = 5.0
    }
    
    func setInitialValues() {
        var fName = ""
        var lName = ""
        var email = ""
        var phone = ""
        if let userDetails = webService.userDetails {
            fName = userDetails["firstName"] ?? ""
            lName = userDetails["lastName"] ?? ""
            email = userDetails["email"] ?? ""
            phone = userDetails["mobileNo"] ?? ""
        }

        firstNameLbl.text = fName
        lastNameLbl.text = lName
        emailLbl.text = email
        phoneLbl.text = phone
        stopAnimating()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == PROFILEVC_TO_EDIT_PROFILEVC {
            let editProfileVc = segue.destination as! ProfileEditVC
            editProfileVc.delegate = self
        }
    }
    
}

extension ProfileVC: UpdateProfileDelegate {
    func profileGotUpdated() {
        setInitialValues()
    }
}
