//
//  BadgeEarnController.swift
//  Royal Australian Navy
//
//  Created by Vijay Rathore on 30/10/23.
//

import UIKit
import SwiftyGif

class BadgeEarnController: UIViewController {
    
    @IBOutlet weak var mView: UIView!
    let logoAnimationView = LogoAnimationView()
    var badge : String?
    override func viewDidLoad() {
        
        mView.addSubview(logoAnimationView)
        logoAnimationView.pinEdgesToSuperView()
        if badge == "BRONZE" {
            logoAnimationView.load(gifName: "bronze.gif")
            
        }
        else if badge == "SILVER" {
            logoAnimationView.load(gifName: "silver.gif")
        }
        else if badge == "GOLD" {
            logoAnimationView.load(gifName: "gold.gif")
        }
        else if badge == "PLATINUM" {
            logoAnimationView.load(gifName: "platinum.gif")
        }
        
        logoAnimationView.logoGifImageView.delegate = self
        logoAnimationView.logoGifImageView.startAnimatingGif()
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
            self.dismiss(animated: true)
        }
        
    }
    override var prefersStatusBarHidden: Bool {
        true
    }
}

extension BadgeEarnController : SwiftyGifDelegate {
    func gifDidStop(sender: UIImageView) {
        logoAnimationView.isHidden = true
    }
}
