//
//  ProfileViewController.swift
//  Royal Australian Navy
//
//  Created by Vijay Rathore on 16/10/23.
//

import UIKit
import FirebaseFirestore
import Firebase

class RoyalProfileViewController : UIViewController {
    
    @IBOutlet weak var logoutBtn: UIButton!
    @IBOutlet weak var infoBtn: UIButton!
    
    @IBOutlet weak var noBadgesEarnedYetLbl: UILabel!
    
    @IBOutlet weak var deleteAccountBnt: UIButton!
    
    @IBOutlet weak var mFullName: UILabel!
    @IBOutlet weak var mEmail: UILabel!
    @IBOutlet weak var bronzeView: UIStackView!
    @IBOutlet weak var silverView: UIStackView!
    @IBOutlet weak var goldView: UIStackView!
    @IBOutlet weak var platinumView: UIStackView!
    
    
    override func viewDidLoad() {
        logoutBtn.layer.cornerRadius = 8
        infoBtn.layer.cornerRadius = 8
        
        deleteAccountBnt.layer.cornerRadius = 8
      
        mFullName.text = UserModel.data!.fullName ?? ""
        mEmail.text = UserModel.data!.email ?? ""
        
        
        let query = Firestore.firestore().collection("Users").document(UserModel.data!.uid!).collection("NavyCompleted")
        let watchQuery = query.count
       
            watchQuery.getAggregation(source: .server) { snapshot, error in
              
                if let snapshot = snapshot {
                    let count = Int(truncating: snapshot.count)
                    if count > 2 {
                        self.noBadgesEarnedYetLbl.isHidden = true
                        self.bronzeView.isHidden = false
                    }
                    if count > 8 {
                        self.silverView.isHidden = false
                    }
                    if count > 17 {
                        self.goldView.isHidden = false
                    }
                    if count > 35 {
                        self.platinumView.isHidden = false
                    }
                    
                }
            }
    }
    
    @IBAction func deleteAccountClicked(_ sender: Any) {
        dismiss(animated: true)

        let alert = UIAlertController(
            title: "DELETE ACCOUNT",
            message: "Are you sure you want to delete your account?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in

            if let user = Auth.auth().currentUser {
                self.ProgressHUDShow(text: "Account Deleting...")
                let userID = user.uid

                user.delete { error in

                    if error == nil {
                        Firestore.firestore().collection("Users").document(userID).delete { error in
                            self.ProgressHUDHide()
                            if error == nil {
                               
                                self.logout()
                            } else {
                                self.showError(error!.localizedDescription)
                            }
                        }
                    } else {
                        self.ProgressHUDHide()
                        let alert = UIAlertController(
                            title: "Re-Login Required",
                            message: "Delete account require re-verification. Please login and try again.",
                            preferredStyle: .alert
                        )
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                            self.logout()
                        }))

                        self.present(alert, animated: true)
                    }
                }
            }
        }))
        present(alert, animated: true)
    }
    
    
    @IBAction func infoClicked(_ sender: Any) {
        performSegue(withIdentifier: "badgeInfoSeg", sender: nil)
    }
    
    @IBAction func logoutClicked(_ sender: Any) {
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Logout", style: .default, handler: { action in
            self.logout()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
}
