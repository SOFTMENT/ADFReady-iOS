//
//  DisclaimerViewController.swift
//  Adf Ready
//
//  Created by Vijay Rathore on 19/11/24.
//

import UIKit

class DisclaimerViewController : UIViewController {
    
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
        userDefault.set(true, forKey: "disclaimers")
        
        self.beRootScreen(mIdentifier: Constants.StroyBoard.continueASViewController)
    }
}
