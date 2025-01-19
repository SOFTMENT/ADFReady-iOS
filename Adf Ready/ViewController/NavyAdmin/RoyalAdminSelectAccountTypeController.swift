//
//  AdminSelectAccountTypeController.swift
//  Royal Australian Navy Fitness
//
//  Created by Vijay Rathore on 11/01/24.
//

import UIKit

class RoyalAdminSelectAccountTypeController : UIViewController {
    @IBOutlet weak var preJoiner: UIButton!
    @IBOutlet weak var navyMember: UIButton!
    
    override func viewDidLoad() {
        preJoiner.isUserInteractionEnabled = true
        navyMember.isUserInteractionEnabled = true
        preJoiner.layer.cornerRadius = 8
        navyMember.layer.cornerRadius = 8
    }
    
    @IBAction func preJoinerClicked(_ sender: Any) {
        performSegue(withIdentifier: "menuSeg", sender: ACCOUNT_TYPE.PREJOINER)
    }
    
    @IBAction func navyMemberClicked(_ sender: Any) {
        performSegue(withIdentifier: "menuSeg", sender: ACCOUNT_TYPE.NAVY)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "menuSeg" {
            if let VC = segue.destination as? RoyalAdminMenuViewController {
                if let accountType = sender as? ACCOUNT_TYPE {
                    VC.accountType = accountType
                }
            }
        }
    }
    
    
}
