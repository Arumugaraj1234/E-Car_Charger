//
//  HistoryVC.swift
//  E-CarCharger
//
//  Created by MacBook Pro on 2019-11-06.
//  Copyright © 2019 Peach. All rights reserved.
//

import UIKit

class HistoryVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setNaviagtionBarTitle(title: "History")
    }
    
    @IBAction func onBackBtnPressed(sender: Any) {
        let main:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let upcomingOrdersVC = main.instantiateViewController(withIdentifier: "NearByChargersNavigation") as! UINavigationController
        present(upcomingOrdersVC, animated: true, completion: nil)
    }


}
