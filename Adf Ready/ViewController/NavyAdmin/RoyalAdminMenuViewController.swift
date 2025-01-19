//
//  AdminMenuViewController.swift
//  Royal Australian Navy Fitness
//
//  Created by Vijay Rathore on 11/01/24.
//

import UIKit
import FirebaseFirestore
import AWSMobileClientXCF
import AWSLocationXCF

class RoyalAdminMenuViewController : UIViewController {
    
    @IBOutlet weak var informationBtn: UIButton!
    @IBOutlet weak var workoutBtn: UIButton!
    @IBOutlet weak var reportBtn: UIButton!
    @IBOutlet weak var navyMembersBtn: UIButton!
    @IBOutlet weak var manageGymBtn: UIButton!
    var accountType : ACCOUNT_TYPE?
    @IBOutlet weak var accountLbl: UILabel!
  
    @IBOutlet weak var backView: UIImageView!
    
    @IBOutlet weak var logoutBtn: UIButton!
    
    override func viewDidLoad() {
        
        guard let accountType = accountType else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }
        
        logoutBtn.layer.cornerRadius = 8
        
        if accountType == .NAVY {
            accountLbl.text = "NAVY MEMBER"
            manageGymBtn.isHidden = false
            navyMembersBtn.isHidden = false
        }
        else {
            manageGymBtn.isHidden = true
            navyMembersBtn.isHidden = true
            accountLbl.text = "PRE-JOINER"
        }
        
        informationBtn.isUserInteractionEnabled = true
        informationBtn.layer.cornerRadius = 8
        
        workoutBtn.isUserInteractionEnabled = true
        workoutBtn.layer.cornerRadius = 8
        
        reportBtn.isUserInteractionEnabled = true
        reportBtn.layer.cornerRadius = 8
        
        navyMembersBtn.layer.cornerRadius = 8
        navyMembersBtn.isUserInteractionEnabled = true
        
        manageGymBtn.layer.cornerRadius = 8
        manageGymBtn.isUserInteractionEnabled = true
        
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
  
    }
    
   
    
    @objc func backViewClicked(){
        self.dismiss(animated: true)
    }
    
    @IBAction func logoutBtnClicked(_ sender: Any) {
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Logout", style: .default, handler: { action in
            self.logout()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
            if segue.identifier == "adminInfoSeg" {
                if let VC = segue.destination as? RoyalInformationsCategoryViewController {
                    VC.accountType = accountType
                }
            }
            else if segue.identifier == "adminWorkoutSeg" {
                if let VC = segue.destination as? RoyalWorkoutCategoryViewController {
                    VC.accountType = accountType
                }
            }
            else if segue.identifier == "reportSeg" {
                if let VC = segue.destination as? RoyalReportViewController {
                    VC.accountType = accountType
                }
            }
            
      
       
    }
    
    @IBAction func informationClicked(_ sender: Any) {
        performSegue(withIdentifier: "adminInfoSeg", sender: nil)
        
    }
    
    @IBAction func workoutClicked(_ sender: Any) {
        performSegue(withIdentifier: "adminWorkoutSeg", sender: nil)
    }
    @IBAction func reportClicked(_ sender: Any) {
        performSegue(withIdentifier: "reportSeg", sender: nil)
    }
    
    @IBAction func navyMemberClicked(_ sender: Any) {
        performSegue(withIdentifier: "navyMemberSeg", sender: nil)
    }
    
    @IBAction func manageGymClicked(_ sender: Any) {
        performSegue(withIdentifier: "manageGymSeg", sender: nil)
    }
}
