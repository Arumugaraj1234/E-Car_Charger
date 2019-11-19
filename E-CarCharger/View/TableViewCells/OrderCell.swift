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
    @IBOutlet weak var vehicleNameLbl: UILabel!
    @IBOutlet weak var otpLbl: UILabel!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var cancelBtnOne: UIButton!
    @IBOutlet weak var otpStackView: UIStackView!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var buttonStackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        totalView.layer.cornerRadius = 10.0
        totalView.layer.borderWidth = 1.0
        totalView.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    }

    func configureCell(order: OrderModel) {
        let rupee = "\u{20B9}"
        bookedDateLbl.text = order.bookedTime
        chargerNameLbl.text = order.chargerName
        fareLbl.text = rupee + String(order.fare)
        vehicleImg.downloadedFrom(link: order.vehicleImageLink)
        vehicleNameLbl.text = order.vehicleName + " - " + "EC123456"
        otpLbl.text = String(order.otp)
        if order.status == "Searching " || order.status == "Cancelled " {
            otpStackView.isHidden = true
            lineView.isHidden = true
            buttonStackView.isHidden = true
        }
        else {
            otpStackView.isHidden = false
            lineView.isHidden = false
            buttonStackView.isHidden = false
        }
    }

}
