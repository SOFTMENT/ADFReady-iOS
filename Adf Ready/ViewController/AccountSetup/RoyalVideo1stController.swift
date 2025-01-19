//
//  ViewController.swift
//  Royal Australian Navy
//
//  Created by Vijay Rathore on 15/10/23.
//

import UIKit
import FirebaseMessaging
import FirebaseAuth
import SwiftyGif

class RoyalVideo1stController : UIViewController {
    
    @IBOutlet weak var mView: UIView!
    let logoAnimationView = LogoAnimationView()
    
    override func viewDidLoad() {
        
        mView.addSubview(logoAnimationView)
        logoAnimationView.pinEdgesToSuperView()
        logoAnimationView.load(gifName: "ezgif.com-video-to-gif-10.gif")
        logoAnimationView.logoGifImageView.delegate = self
        
        logoAnimationView.logoGifImageView.startAnimatingGif()
        //SUBSCRIBE TO TOPIC
        Messaging.messaging().subscribe(toTopic: "ran"){ error in
            if error == nil{
                print("Subscribed to topic")
            }
            else{
                print("Not Subscribed to topic")
            }
        }
 
        let userDefaults = UserDefaults.standard
        if userDefaults.value(forKey: "appFirstTimeOpend") == nil {
         
            userDefaults.setValue(true, forKey: "appFirstTimeOpend")
      
            do {
                try Auth.auth().signOut()
            }catch {
                
            }
          
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            
            if let user = Auth.auth().currentUser  {
              
                    if user.uid == "tsVJ4vKkpjSvUzCpQ9w88JB3adC3" {
                        self.beRootScreen(mIdentifier: Constants.StroyBoard.adminTabBarViewController)
                    }
                    else {
                        let userDefault  = UserDefaults.standard
                        if let accountType = userDefault.string(forKey: "AccountType") {
                            
                            if accountType == "user" {
                                self.getRoyalUserData(collectionName: "Users", uid: Auth.auth().currentUser!.uid, showProgress: false)
                            }
                            else {
                                self.getRoyalUserData(collectionName: "NavyMembers", uid: Auth.auth().currentUser!.uid, showProgress: false)
                            }
                        }
                        else {
                            self.beRootScreen(mIdentifier: Constants.StroyBoard.entryViewController)
                        }
                      
                    }
                
            }
            else {
                
                DispatchQueue.main.async {
                    if userDefaults.bool(forKey: "disclaimer"){
                        self.beRootScreen(mIdentifier: Constants.StroyBoard.entryViewController)
                    }
                    else {
                        self.performSegue(withIdentifier: "disclaimerSeg", sender: nil)
                    }
                    
                   
                }
                
            }
        }
        
    }
    override var prefersStatusBarHidden: Bool {
        true
    }
}


enum VersionError: Error {
    case invalidResponse, invalidBundleInfo
}
extension RoyalVideo1stController : SwiftyGifDelegate {
    func gifDidStop(sender: UIImageView) {
        logoAnimationView.isHidden = true
    }
}
