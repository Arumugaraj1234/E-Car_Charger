//
//  OrderConfirmationPopVC.swift
//  E-CarCharger
//
//  Created by MacBook Pro on 2019-11-06.
//  Copyright © 2019 Peach. All rights reserved.
//

import UIKit

protocol orderConfimationDelegate {
    func orderGotConfirmed(tag: Int)
}
class OrderConfirmationPopVC: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var totalView: UIView!
    @IBOutlet weak var bgImage: UIImageView!
    
    //MARK: Variables
    var delegate: orderConfimationDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        totalView.layer.cornerRadius = 20.0
        bgImage.layer.cornerRadius = 20.0
        bgImage.clipsToBounds = true
        
    }
    
    @IBAction func onOkBtnPressed(sender: UIButton) {
        delegate?.orderGotConfirmed(tag: 1)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onTrackBtnPressed(sender: UIButton) {
        delegate?.orderGotConfirmed(tag: 2)
        dismiss(animated: true, completion: nil)
    }

}
