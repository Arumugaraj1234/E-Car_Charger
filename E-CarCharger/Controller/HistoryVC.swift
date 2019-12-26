//
//  HistoryVC.swift
//  E-CarCharger
//
//  Created by MacBook Pro on 2019-11-06.
//  Copyright © 2019 Peach. All rights reserved.
//

import UIKit
import SideMenu

class HistoryVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var orders = [OrderModel]()
    let webService = WebRequestService.shared
    var chargerId: Int?

    override func viewDidLoad() {
        super.viewDidLoad()

        getOrderHistory()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 143
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setNaviagtionBarTitle(title: "My Bookings")
    }
    
    @IBAction func onBackBtnPressed(sender: Any) {
        let menu = storyboard!.instantiateViewController(withIdentifier: "SideMenu") as! UISideMenuNavigationController
        menu.sideMenuManager.menuPresentMode = .menuDissolveIn
        present(menu, animated: true, completion: nil)
    }
    
    @IBAction func onCancelBtnPressed(sender: UIButton) {
        let index = sender.tag
        let orderId = orders[index].orderId
        cancelOrder(orderId: orderId)
    }
    
    @IBAction func onTrackBtnPressed(sender: UIButton) {
        let index = sender.tag
        self.chargerId = orders[index].chargerId
        performSegue(withIdentifier: HISTORYVC_TO_TRACK_CHARGER, sender: self)
    }

    func getOrderHistory() {
        if checkInternetAvailablity() {
            startAnimate(with: "")
            webService.getOrderHistory(userId: webService.userId) { (status, message, data) in
                if status == 1 {
                    self.orders = data!
                    self.tableView.reloadData()
                    self.stopAnimating()
                    if self.orders.count == 0 {
                        self.makeToast(message: "No orders found in history", time: 3.0, position: .center, textColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
                    }
                }
                else {
                    self.stopAnimating()
                    _ = SweetAlert().showAlert("Failed", subTitle: message, style: .none)
                    //self.makeToast(message: message, time: 3.0, position: .bottom)
                }
            }
        }
        else {
            makeToast(message: "Your internet is weak or unavailable. Please check & try again!", time: 3.0, position: .bottom, textColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
        }
    }
    
    func cancelOrder(orderId: Int) {
        if checkInternetAvailablity() {
            startAnimating()
            webService.cancelOrderByUser(orderId: orderId, userId: webService.userId) { (status, message, data) in
                if status == 1 {
                    self.orders = data!
                    //self.tableView.reloadData()
                    self.stopAnimating()
                    _ = SweetAlert().showAlert("Cancelled!", subTitle: message, style: .none, buttonTitle: "OK", action: { (status) in
                        self.tableView.reloadData()
                    })
                }
                else {
                    self.stopAnimating()
                    _ = SweetAlert().showAlert("Failed!", subTitle: message, style: .none)
                    //self.makeToast(message: message, time: 3.0, position: .bottom)
                }
            }
        }
        else {
            makeToast(message: "Your internet is weak or unavailable. Please check & try again!", time: 3.0, position: .bottom, textColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == HISTORYVC_TO_TRACK_CHARGER {
            let trackVc = segue.destination as! TrackChargerVC
            trackVc.chargerId = self.chargerId!
            trackVc.myCurrentLatitude = LocationService.shared.myCurrentLatitude
            trackVc.myCurrentLongitude = LocationService.shared.myCurrentLongitude
        }
    }
    
}

extension HistoryVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "OrderCell", for: indexPath) as? OrderCell else {return UITableViewCell()}
        cell.cancelBtn.tag = indexPath.row
        cell.trackBtn.tag = indexPath.row
        cell.cancelBtnOne.tag = indexPath.row
        let order = orders[indexPath.row]
        cell.configureCell(order: order)
        return cell
    }
    
}
