//
//  WelcomeViewController2.swift
//  Adf Ready
//
//  Created by Vijay Rathore on 15/11/24.
//

import UIKit

class WelcomeViewController2 : UIViewController {
    
    override func viewDidLoad() {
        
        let userDefaults = UserDefaults.standard
        if userDefaults.value(forKey: "appFirstTimeOpend") == nil {
         
            userDefaults.setValue(true, forKey: "appFirstTimeOpend")
      
            do {
                try FirebaseStoreManager.auth.signOut()
            }catch {
                
            }
          
        }
    
        if let user =  FirebaseStoreManager.auth.currentUser {
            
            self.getUserData(uid: user.uid, showProgress: false)
            
        }
        else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7 ) {
                self.beRootScreen(mIdentifier: Constants.StroyBoard.continueASViewController)
            }
           
        }
    }
        
   
}


