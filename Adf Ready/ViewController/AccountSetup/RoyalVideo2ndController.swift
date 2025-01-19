//
//  Video2ndController.swift
//  Royal Australian Navy
//
//  Created by Vijay Rathore on 15/10/23.
//

import UIKit
import SwiftyGif

class RoyalVideo2ndController : UIViewController {
    
    @IBOutlet weak var mView: UIView!
    let logoAnimationView = LogoAnimationView()
    var accountType : ACCOUNT_TYPE?
    override func viewDidLoad() {
        
        guard let accountType = accountType else {
            
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }
        
        mView.addSubview(logoAnimationView)
        logoAnimationView.pinEdgesToSuperView()
        logoAnimationView.load(gifName: "ezgif.com-video-to-gif-12.gif")
        logoAnimationView.logoGifImageView.delegate = self
        logoAnimationView.logoGifImageView.startAnimatingGif()
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.performSegue(withIdentifier: "loginSeg", sender: accountType)
        }
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "loginSeg" {
            if let VC = segue.destination as? RoyalLoginViewController {
                VC.accountType = self.accountType
            }
        }
    }
    override var prefersStatusBarHidden: Bool {
        true
    }
    
    
}

extension RoyalVideo2ndController : SwiftyGifDelegate {
    func gifDidStop(sender: UIImageView) {
        logoAnimationView.isHidden = true
    }
}
