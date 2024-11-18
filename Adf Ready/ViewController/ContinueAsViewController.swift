//
//  ContinueAsViewController.swift
//  Adf Ready
//
//  Created by Vijay Rathore on 17/11/24.
//

import UIKit


class ContinueAsViewController : UIViewController {
    
    @IBOutlet weak var preJoinerView: RoundedView!
    
    
    @IBOutlet weak var navyView: RoundedView!
    
    override func viewDidLoad() {
        preJoinerView.isUserInteractionEnabled = true
        preJoinerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(preJoinerClicked)))
        
        navyView.isUserInteractionEnabled = true
        navyView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(navyMemberClicked)))
    }
    
    @objc func preJoinerClicked() {
        performSegue(withIdentifier: "signInSeg", sender: nil)
    }
    
    @objc func navyMemberClicked() {
        // Replace with the URL scheme of the Navy app if available
        let appURL = URL(string: "navyfitness://")!
        
        // App Store fallback URL
        let appStoreURL = URL(string: "https://apps.apple.com/in/app/royal-australian-navy-fitness/id6469463262")!
        
        if UIApplication.shared.canOpenURL(appURL) {
            // Open the app
            UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
        } else {
            // Redirect to App Store
            UIApplication.shared.open(appStoreURL, options: [:], completionHandler: nil)
        }

    }
    
}
