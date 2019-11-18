//
//  HistoryVC.swift
//  E-CarCharger
//
//  Created by MacBook Pro on 2019-11-06.
//  Copyright © 2019 Peach. All rights reserved.
//

import UIKit

class HistoryVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var orders = [OrderModel]()
    let webService = WebRequestService.shared

    override func viewDidLoad() {
        super.viewDidLoad()

        getOrderHistory()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setNaviagtionBarTitle(title: "My Bookings")
    }
    
    @IBAction func onBackBtnPressed(sender: Any) {
        let main:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let upcomingOrdersVC = main.instantiateViewController(withIdentifier: "NearByChargersNavigation") as! UINavigationController
        present(upcomingOrdersVC, animated: true, completion: nil)
    }
    
    @IBAction func onCancelBtnPressed(sender: UIButton) {
        let index = sender.tag
        let orderId = orders[index].orderId
        cancelOrder(orderId: orderId)
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
                        self.makeToast(message: "No orders found in history", time: 3.0, position: .bottom)
                    }
                }
                else {
                    self.stopAnimating()
                    self.makeToast(message: message, time: 3.0, position: .bottom)
                }
            }
        }
        else {
            makeToast(message: "Your internet is weak or unavailable. Please check & try again!", time: 3.0, position: .bottom)
        }
    }
    
    func cancelOrder(orderId: Int) {
        if checkInternetAvailablity() {
            startAnimating()
            webService.cancelOrderByUser(orderId: orderId, userId: webService.userId) { (status, message, data) in
                if status == 1 {
                    self.orders = data!
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
            makeToast(message: "Your internet is weak or unavailable. Please check & try again!", time: 3.0, position: .bottom)
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
        cell.cancelBtnOne.tag = indexPath.row
        let order = orders[indexPath.row]
        cell.configureCell(order: order)
        return cell
    }
}
