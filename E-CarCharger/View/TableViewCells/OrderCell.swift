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

    override func awakeFromNib() {
        super.awakeFromNib()
        totalView.layer.cornerRadius = 10.0
        totalView.layer.borderWidth = 1.0
        totalView.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    }

    func configureCell(order: OrderModel) {
        bookedDateLbl.text = order.bookedTime
        chargerNameLbl.text = order.chargerName
        fareLbl.text = String(order.fare)
        vehicleImg.downloadedFrom(link: order.vehicleImageLink)
        vehicleNameLbl.text = order.vehicleName
        otpLbl.text = String(order.otp)
    }

}
