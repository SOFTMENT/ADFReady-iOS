//
//  DisclaimerViewController.swift
//  Royal Australian Navy
//
//  Created by Vijay Rathore on 15/10/23.
//

import UIKit

class RoyalDisclaimerViewController : UIViewController {
    
    @IBOutlet weak var checkBtn: UIImageView!
    @IBOutlet weak var disclaimerBack: UIView!
    override func viewDidLoad() {
        disclaimerBack.dropShadow()
        disclaimerBack.layer.cornerRadius = 8
        
        checkBtn.isUserInteractionEnabled = true
        checkBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(checkClicked)))
    }
    
    @objc func checkClicked(){
        
        let userDefault = UserDefaults.standard
        userDefault.set(true, forKey: "disclaimer")
        
        self.beRootScreen(mIdentifier: Constants.StroyBoard.entryViewController)
    }
}
