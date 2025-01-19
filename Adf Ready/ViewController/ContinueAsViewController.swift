//
//  ContinueAsViewController.swift
//  Adf Ready
//
//  Created by Vijay Rathore on 17/11/24.
//

import UIKit


class ContinueAsViewController : UIViewController {
    
    @IBOutlet weak var preJoinerView: RoundedView!
    
    @IBOutlet weak var armyView: RoundedView!
    
    @IBOutlet weak var airForceView: RoundedView!
    @IBOutlet weak var navyView: RoundedView!
    
    override func viewDidLoad() {
        preJoinerView.isUserInteractionEnabled = true
        preJoinerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(preJoinerClicked)))
        
        navyView.isUserInteractionEnabled = true
        navyView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(navyMemberClicked)))
        
        armyView.isUserInteractionEnabled = true
        armyView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(commingSoonClicked)))
        
        airForceView.isUserInteractionEnabled = true
        airForceView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(commingSoonClicked)))
    }
    
    
    
    
    @objc func commingSoonClicked() {
        self.showToast(message: "Coming Soon...")
    }
    
    
    
    @objc func preJoinerClicked() {
        performSegue(withIdentifier: "signInSeg", sender: nil)
    }
    
    @objc func navyMemberClicked() {
        self.beRootScreen(mIdentifier: Constants.StroyBoard.video1ViewController)

    }
    
}
