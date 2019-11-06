//
//  SideMenuVC.swift
//  E-CarCharger
//
//  Created by MacBook Pro on 2019-11-05.
//  Copyright © 2019 Peach. All rights reserved.
//

import UIKit

class SideMenuVC: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    //Variables
    let menuDetails: [SideMenuModel] = [
        SideMenuModel(menuName: "Home", whiteMenuIcon: UIImage(named: "white_Home")!, blueMenuIcon: UIImage(named: "blue_Home")!),
        SideMenuModel(menuName: "Profile", whiteMenuIcon: UIImage(named: "white_Profile")!, blueMenuIcon: UIImage(named: "blue_Profile")!),
        SideMenuModel(menuName: "History", whiteMenuIcon: UIImage(named: "white_History")!, blueMenuIcon: UIImage(named: "blue_History")!)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
}

extension SideMenuVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuDetails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuCell", for: indexPath) as? SideMenuCell else {return UITableViewCell() }
        let menu = menuDetails[indexPath.row]
        cell.configureCell(menu: menu, index: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        func shouldSelect() -> Bool {
            if indexPath.row == 0 {
                return true
            }
            return false
        }
        if shouldSelect() {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.tableView.cellForRow(at: indexPath) as! SideMenuCell
        let menu = menuDetails[indexPath.row]
        cell.menuIconImg.image = menu.blueMenuIcon
        
        if indexPath.row == 0 {
            let main:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let homeVC = main.instantiateViewController(withIdentifier: "NearByChargersNavigation") as! UINavigationController
            present(homeVC, animated: true, completion: nil)
        }
        else if indexPath.row == 2 {
            let main:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let historyVC = main.instantiateViewController(withIdentifier: "HistoryNaviagtion") as! UINavigationController
            present(historyVC, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = self.tableView.cellForRow(at: indexPath) as! SideMenuCell
        let menu = menuDetails[indexPath.row]
        cell.menuIconImg.image = menu.whiteMenuIcon
    }

}
