//
//  OrderCell.swift
//  E-CarCharger
//
//  Created by MacBook Pro on 2019-11-18.
//  Copyright © 2019 Peach. All rights reserved.
//

import UIKit

class OrderCell: UITableViewCell {
    
    @IBOutlet weak var totalView: UIView!
    @IBOutlet weak var bookedDateLbl: UILabel!
    @IBOutlet weak var chargerNameLbl: UILabel!
    @IBOutlet weak var fareLbl: UILabel!
    @IBOutlet weak var vehicleImg: UIImageView!
    @IBOutlet weak var orderRefNoLbl: UILabel!
    @IBOutlet weak var otpLbl: UILabel!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var cancelBtnOne: UIButton!
    @IBOutlet weak var otpStackView: UIStackView!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var buttonStackView: UIStackView!
    @IBOutlet weak var trackBtn: UIButton!
    @IBOutlet weak var totalTimeStackView: UIStackView!
    @IBOutlet weak var totalTimeLbl: UILabel!
    @IBOutlet weak var paymentStatusImg: UIImageView!
    
    let cancelledIcon = UIImage(named: "unpaidIcon")!
    let inServiceIcon = UIImage(named: "unpaidIcon")!
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        totalView.layer.cornerRadius = 10.0
//        totalView.layer.borderWidth = 1.0
//        totalView.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    }

    func configureCell(order: OrderModel) {
        let rupee = "\u{20B9}"
        bookedDateLbl.text = order.bookedTime
        vehicleImg.downloadedFrom(link: order.vehicleImageLink)
        orderRefNoLbl.text = "\(order.orderId)"
        
        if order.status == "Cancelled " {
            chargerNameLbl.text = "--"
            otpStackView.isHidden = true
            totalTimeStackView.isHidden = false
            totalTimeLbl.text = "__:__:__"
            fareLbl.text = "-"
            paymentStatusImg.image = cancelledIcon
            lineView.isHidden = true
            buttonStackView.isHidden = true
        }
        else if order.status == "Booked " {
            chargerNameLbl.text = order.chargerName
            otpStackView.isHidden = false
            otpLbl.text = "\(order.otp)"
            totalTimeStackView.isHidden = true
            fareLbl.text = rupee + "\(order.fare)"
            paymentStatusImg.image = inServiceIcon
            lineView.isHidden = false
            buttonStackView.isHidden = false
        }
        else if order.status == "Charging " {
            chargerNameLbl.text = order.chargerName
            otpStackView.isHidden = false
            otpLbl.text = "\(order.otp)"
            totalTimeStackView.isHidden = true
            fareLbl.text = rupee + "\(order.fare)"
            paymentStatusImg.image = inServiceIcon
            lineView.isHidden = true
            buttonStackView.isHidden = true
        }
        else if order.status == "Completed " {
            chargerNameLbl.text = order.chargerName
            otpStackView.isHidden = true
            totalTimeStackView.isHidden = false
            totalTimeLbl.text = "01:28:35"
            fareLbl.text = rupee + "\(order.fare)"
            paymentStatusImg.image = inServiceIcon
            lineView.isHidden = true
            buttonStackView.isHidden = true
        }
        
        
//        chargerNameLbl.text = order.chargerName
//        
//        fareLbl.text = rupee + String(order.fare)
//        
//        
//        otpLbl.text = String(order.otp)
//        if order.status == "Searching " || order.status == "Cancelled " {
//            otpStackView.isHidden = true
//            lineView.isHidden = true
//            buttonStackView.isHidden = true
//        }
//        else {
//            otpStackView.isHidden = false
//            lineView.isHidden = false
//            buttonStackView.isHidden = false
//        }
    }

}
