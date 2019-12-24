//
//  SideMenuCell.swift
//  E-CarCharger
//
//  Created by MacBook Pro on 2019-11-05.
//  Copyright © 2019 Peach. All rights reserved.
//

import UIKit

class SideMenuCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var menuIconImg: UIImageView!
    @IBOutlet weak var menuNameLbl: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.roundCorners(corners: [.bottomLeft, .topLeft], radius: 20.0)
    }
    
    func configureCell(menu: SideMenuModel, index: Int) {
        menuNameLbl.text = menu.menuName
        if WebRequestService.shared.selectedIndexAtSideMenu == index {
            containerView.backgroundColor = UIColor.white
            menuNameLbl.textColor = #colorLiteral(red: 0.5803921569, green: 0.09019607843, blue: 0.3176470588, alpha: 1)
            menuIconImg.image = menu.whiteMenuIcon
        }
        else {
            containerView.backgroundColor = UIColor.clear
            menuNameLbl.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            menuIconImg.image = menu.blueMenuIcon
        }
    }
    
    
}
