//
//  BadgeInfoViewController.swift
//  Royal Australian Navy
//
//  Created by Vijay Rathore on 26/10/23.
//

import UIKit
import Firebase

class BadgeInfoViewController : UIViewController {
    
    
    @IBOutlet weak var youhaveCompletedSessionsBtn: UIButton!
    @IBOutlet weak var backView: UIImageView!
    
    override func viewDidLoad() {
    
        youhaveCompletedSessionsBtn.layer.cornerRadius = 8
        
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnClicked)))
        
        let query = Firestore.firestore().collection("Users").document(UserModel.data!.uid!).collection("NavyCompleted")
        let watchQuery = query.count
        self.ProgressHUDShow(text: "")
            watchQuery.getAggregation(source: .server) { snapshot, error in
                self.ProgressHUDHide()
                if let snapshot = snapshot {
                    self.youhaveCompletedSessionsBtn.setTitle("You've completed \(snapshot.count) sessions", for: .normal)
                }
            }
    }
    
    @objc func backBtnClicked(){
        self.dismiss(animated: true)
    }
    
    
    
}
