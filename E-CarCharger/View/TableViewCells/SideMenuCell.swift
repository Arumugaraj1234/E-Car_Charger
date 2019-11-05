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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            containerView.backgroundColor = UIColor.white
            menuNameLbl.textColor = #colorLiteral(red: 0.1432973146, green: 0.2453835607, blue: 0.3625246882, alpha: 1)
        }
        else {
            containerView.backgroundColor = UIColor.clear
            menuNameLbl.textColor = UIColor.white
        }
    }
    
    func configureCell(menu: SideMenuModel, index: Int) {
        menuNameLbl.text = menu.menuName
        if index == 0 {
            menuIconImg.image = menu.blueMenuIcon
        }
        else {
            menuIconImg.image = menu.whiteMenuIcon
        }
    }
    
}
