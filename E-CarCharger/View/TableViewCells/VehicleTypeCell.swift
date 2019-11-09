//
//  VehicleTypeCell.swift
//  E-CarCharger
//
//  Created by MacBook Pro on 2019-11-09.
//  Copyright © 2019 Peach. All rights reserved.
//

import UIKit

class VehicleTypeCell: UITableViewCell {
    
    @IBOutlet weak var fadedView: UIView!
    @IBOutlet weak var vehicleIcon: UIImageView!
    @IBOutlet weak var vehicleName: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        fadedView.layer.cornerRadius = 10.0
    }
    
    func configureCell(vehicle: VehicleTypeModel) {
        vehicleIcon.downloadedFrom(link: vehicle.imageLink)
        vehicleName.text = vehicle.name
    }

}
