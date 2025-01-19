//
//  SignUpViewController.swift
//  Adf Ready
//
//  Created by Vijay Rathore on 15/11/24.
//

import UIKit

class SignUpViewController : UIViewController {
    
    @IBOutlet weak var backView: UIImageView!
    @IBOutlet weak var fullNameTF: CustomTextField!
    @IBOutlet weak var emailTF: CustomTextField!
    @IBOutlet weak var passwordTF: CustomTextField!
    @IBOutlet weak var ageGroupTF: CustomTextField!
    @IBOutlet weak var stateTF: CustomTextField!
    @IBOutlet weak var genderTF: CustomTextField!
    @IBOutlet weak var reasonForDownloadTF: CustomTextField!
   
    @IBOutlet weak var loginLbl: UILabel!
    
    
    
    override func viewDidLoad() {
        loginLbl.isUserInteractionEnabled = true
        loginLbl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(loginClicked)))
        
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnClicked)))
        
        fullNameTF.delegate = self
        emailTF.delegate = self
        passwordTF.delegate = self
        ageGroupTF.delegate = self
      
        stateTF.delegate = self
        stateTF.isUserInteractionEnabled = true
        stateTF.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showStateSelection)))
        stateTF.setRightIcons(icon: UIImage(named: "down-arrow")!)
        genderTF.delegate = self
        genderTF.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showGenderSelection)))
        genderTF.setRightIcons(icon: UIImage(named: "down-arrow")!)
        reasonForDownloadTF.delegate = self
        reasonForDownloadTF.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showReasonForDownloadSelection)))
        reasonForDownloadTF.setRightIcons(icon: UIImage(named: "down-arrow")!)
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }
 
    
    
    @objc func showReasonForDownloadSelection() {
          let alertController = UIAlertController(title: "Select a Download Reason", message: nil, preferredStyle: .actionSheet)
          
        for state in Constants.reasonForDownloading {
              let action = UIAlertAction(title: state, style: .default) { _ in
                  self.reasonForDownloadTF.text = state
              }
              alertController.addAction(action)
          }
          
          // Add a cancel option
          let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
          alertController.addAction(cancelAction)
          
          // Present the alert controller as an action sheet
          if let popoverController = alertController.popoverPresentationController {
              popoverController.sourceView = reasonForDownloadTF
              popoverController.sourceRect = reasonForDownloadTF.bounds
          }
          present(alertController, animated: true, completion: nil)
      }
    
    @objc func showGenderSelection() {
          let alertController = UIAlertController(title: "Select a Gender", message: nil, preferredStyle: .actionSheet)
          
        for state in Constants.genders {
              let action = UIAlertAction(title: state, style: .default) { _ in
                  self.genderTF.text = state
              }
              alertController.addAction(action)
          }
          
          // Add a cancel option
          let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
          alertController.addAction(cancelAction)
          
          // Present the alert controller as an action sheet
          if let popoverController = alertController.popoverPresentationController {
              popoverController.sourceView = genderTF
              popoverController.sourceRect = genderTF.bounds
          }
          present(alertController, animated: true, completion: nil)
      }
    
    @objc func showStateSelection() {
          let alertController = UIAlertController(title: "Select a State", message: nil, preferredStyle: .actionSheet)
          
        for state in Constants.states {
              let action = UIAlertAction(title: state, style: .default) { _ in
                  self.stateTF.text = state
              }
              alertController.addAction(action)
          }
          
          // Add a cancel option
          let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
          alertController.addAction(cancelAction)
          
          // Present the alert controller as an action sheet
          if let popoverController = alertController.popoverPresentationController {
              popoverController.sourceView = stateTF
              popoverController.sourceRect = stateTF.bounds
          }
          present(alertController, animated: true, completion: nil)
      }
    
    @objc func backBtnClicked() {
        self.dismiss(animated: true)
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    @objc func loginClicked() {
        self.dismiss(animated: true)
    }
    
    @IBAction func registerBtnClicked(_ sender: Any) {
        guard let sFullname = fullNameTF .text, !sFullname.isEmpty else {
            self.showToast(message: "Please enter your full name")
            return
        }
        guard let sEmail = emailTF.text, !sEmail.isEmpty else {
            self.showToast(message: "Please enter your email")
            return
        }
        guard let sPassword = passwordTF.text, !sPassword.isEmpty else {
            self.showToast(message: "Please enter your password")
            return
        }
        guard let sAgeGroup = ageGroupTF.text, !sAgeGroup.isEmpty else {
            self.showToast(message: "Please Enter Your Age")
            return
        }
        guard let sState = stateTF.text, !sState.isEmpty else {
            self.showToast(message: "Please select your state")
            return
        }
        guard let sGender = genderTF.text, !sGender.isEmpty else {
            self.showToast(message: "Please select your gender")
            return
        }
        guard let sReason = reasonForDownloadTF.text, !sReason.isEmpty else {
            self.showToast(message: "Please select app download reason")
            return
        }
        
        self.ProgressHUDShow(text: "Registering...")
        FirebaseStoreManager.auth.createUser(withEmail: sEmail, password: sPassword) { result, error in
          
            if let error {
                self.ProgressHUDHide()
                self.showToast(message: error.localizedDescription)
            } else {
                let userModel = UserModel()
                userModel.fullName = sFullname
                userModel.email = sEmail
                userModel.ageGroup = sAgeGroup
                userModel.state = sState
                userModel.gender = sGender
                userModel.reasonForDownload = sReason
                userModel.uid = result!.user.uid
                userModel.createDate = Date()
                self.addUserDetails(userModel)
            }
        }
    }
    
    func addUserDetails(_ userModel : UserModel) {
        
        try? FirebaseStoreManager.db.collection("Users").document(userModel.uid!).setData(from: userModel) { error in
            self.ProgressHUDHide()
            if let error {
                print("Error adding user details: \(error.localizedDescription)")
            }
            else {
                self.getUserData(uid: userModel.uid!, showProgress: true)
            }
        }
      
    }
}

extension SignUpViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
}
