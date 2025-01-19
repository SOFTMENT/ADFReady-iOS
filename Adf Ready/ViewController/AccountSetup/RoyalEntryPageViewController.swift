//
//  EntryPageViewController.swift
//  Royal Australian Navy
//
//  Created by Vijay Rathore on 15/10/23.
//

import UIKit

class RoyalEntryPageViewController : UIViewController {
    
    @IBOutlet weak var backView: UIImageView!
    @IBOutlet weak var newJoinerBtn: UIButton!
    @IBOutlet weak var navyMemberBtn: UIButton!
    override func viewDidLoad() {
        newJoinerBtn.layer.cornerRadius = 8
        newJoinerBtn.layer.borderWidth = 2
        newJoinerBtn.layer.borderColor = UIColor(red: 34/255, green: 66/255, blue: 112/255, alpha: 1).cgColor
        
        navyMemberBtn.layer.cornerRadius = 8
        
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
    }
    
    @objc func backViewClicked(){
        self.beRootScreen(mIdentifier: Constants.StroyBoard.continueASViewController)
    }
    
    @IBAction func newJoinerClicked(_ sender: Any) {
      
        performSegue(withIdentifier: "video2ndSeg", sender: ACCOUNT_TYPE.PREJOINER)
    }
    @IBAction func navyMemberClicked(_ sender: Any) {
        performSegue(withIdentifier: "video2ndSeg", sender: ACCOUNT_TYPE.NAVY)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "video2ndSeg" {
            if let VC = segue.destination as? RoyalVideo2ndController {
                if let accountType = sender as? ACCOUNT_TYPE {
                    VC.accountType = accountType
                }
            }
        }
    }
}

enum ACCOUNT_TYPE {
    case NAVY
    case PREJOINER
}
