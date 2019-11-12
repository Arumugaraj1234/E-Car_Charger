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
    @IBOutlet weak var dashedViewFour: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

        //dashedViewOne.makeDashedBorderLine()
        dashedViewTwo.makeDashedBorderLine()
        dashedViewThree.makeDashedBorderLine()
        dashedViewFour.makeDashedBorderLine()
    }


    

    


}
