//
//  ChargerStatusCell.swift
//  E-CarCharger
//
//  Created by MacBook Pro on 2019-11-12.
//  Copyright © 2019 Peach. All rights reserved.
//

import UIKit

class ChargerStatusCell: UITableViewCell {
    
    @IBOutlet weak var dashedViewOne: UIView!
    @IBOutlet weak var dashedViewTwo: UIView!
    @IBOutlet weak var dashedViewThree: UIView!
    @IBOutlet weak var statusImgaeOne: UIImageView!
    @IBOutlet weak var statusImageTwo: UIImageView!
    @IBOutlet weak var statusImageThree: UIImageView!
    @IBOutlet weak var statusImageFour: UIImageView!
    @IBOutlet weak var orderBookedLbl: UILabel!
    @IBOutlet weak var chargerOnTheWayLbl: UILabel!
    @IBOutlet weak var chargingLbl: UILabel!
    @IBOutlet weak var completeLbl: UILabel!
    
    let emptyCircleImg = UIImage(named: "emptyCircle")!
    let selectedCircleImg = UIImage(named: "onStatusCircle")!
    let completedCircleImg = UIImage(named: "completedCircle")!
    
    let normalFont = UIFont(name: "Futura-CondensedMedium", size: 16.0)
    let highlightedFont = UIFont(name: "Futura-CondensedMedium", size: 20.0)
    

    override func awakeFromNib() {
        super.awakeFromNib()

//        //dashedViewOne.makeDashedBorderLine()
//        dashedViewTwo.makeDashedBorderLine()
//        dashedViewThree.makeDashedBorderLine()
    }


    func configureCell(status: Int) {
        if status == 1 {
            statusImgaeOne.image = completedCircleImg
            orderBookedLbl.font = normalFont
            dashedViewOne.backgroundColor = UIColor.black
            statusImageTwo.image = selectedCircleImg
            chargerOnTheWayLbl.font = highlightedFont
            dashedViewTwo.makeDashedBorderLine()
            statusImageThree.image = emptyCircleImg
            chargingLbl.font = normalFont
            dashedViewThree.makeDashedBorderLine()
            statusImageFour.image = emptyCircleImg
            completeLbl.font = normalFont
        }
        else if status == 2 {
            statusImgaeOne.image = completedCircleImg
            orderBookedLbl.font = normalFont
            dashedViewOne.backgroundColor = UIColor.black
            statusImageTwo.image = completedCircleImg
            chargerOnTheWayLbl.font = normalFont
            dashedViewTwo.backgroundColor = UIColor.black
            statusImageThree.image = selectedCircleImg
            chargingLbl.font = highlightedFont
            dashedViewThree.makeDashedBorderLine()
            statusImageFour.image = emptyCircleImg
            completeLbl.font = normalFont
        }
        else if status == 3 {
            statusImgaeOne.image = completedCircleImg
            orderBookedLbl.font = normalFont
            dashedViewOne.backgroundColor = UIColor.black
            statusImageTwo.image = completedCircleImg
            chargerOnTheWayLbl.font = normalFont
            dashedViewTwo.backgroundColor = UIColor.black
            statusImageThree.image = completedCircleImg
            chargingLbl.font = normalFont
            dashedViewThree.backgroundColor = UIColor.black
            statusImageFour.image = completedCircleImg
            completeLbl.font = highlightedFont
        }
    }

    


}
