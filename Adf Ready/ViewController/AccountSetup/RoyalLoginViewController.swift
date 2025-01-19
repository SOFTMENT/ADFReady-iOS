//
//  LoginViewController.swift
//  Royal Australian Navy
//
//  Created by Vijay Rathore on 16/10/23.
//

import UIKit
import FirebaseAuth
import Firebase

class RoyalLoginViewController : UIViewController {
    
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var forgotPassword: UILabel!
    @IBOutlet weak var backView: UIImageView!
    
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var createNewAccountBtn: UILabel!
    var accountType : ACCOUNT_TYPE?
    
    @IBOutlet weak var loginLbl: UILabel!
    override func viewDidLoad() {
        
        
        guard accountType != nil else {
            
            DispatchQueue.main.async {
                self.logout()
                
            }
            return
            
        }
        
        if accountType == .PREJOINER {
            loginLbl.text = "Pre-Joiner Login"
        }
        else {
            loginLbl.text = "Navy Member Login"
        }

        
        emailTF.delegate = self
        passwordTF.delegate = self
        
        loginBtn.layer.cornerRadius = 8
        
        forgotPassword.isUserInteractionEnabled = true
        forgotPassword.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(forgotPasswordClicked)))
        
        createNewAccountBtn.isUserInteractionEnabled = true
        createNewAccountBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(createNewAccount)))

        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked)))
    }
    
    @objc func backViewClicked(){
        self.beRootScreen(mIdentifier: Constants.StroyBoard.entryViewController)
    }
    
    @objc func createNewAccount(){
        performSegue(withIdentifier: "signUpSeg", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "signUpSeg" {
            if let VC = segue.destination as? RoyalSignUpViewController {
                VC.accountType = self.accountType
            }
        }
    }
    @objc func forgotPasswordClicked(){
        let sEmail = emailTF.text
        if sEmail == "" {
            self.showToast(message: "Enter Email Address")
        }
        else {
            self.ProgressHUDShow(text: "")
            Auth.auth().sendPasswordReset(withEmail: sEmail!) { error in
                self.ProgressHUDHide()
                if let error = error {
                    self.showError(error.localizedDescription)
                }
                else {
                    self.showMessage(title: "Password Reset", message: "We have sent password reset link to your mail address.", shouldDismiss: false)
                }
            }
        }
    }
    
    @objc func viewClicked(){
        self.view.endEditing(true)
    }
    
    @IBAction func loginBtnClicked(_ sender: Any) {
        
        let sEmail = emailTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let sPassword = passwordTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if sEmail == "" {
            self.showToast(message: "Enter Email Address")
        }
        else if sPassword == "" {
            self.showToast(message: "Enter Password")
        }
         else {
              
             if self.accountType == .PREJOINER {
                 self.continueForSignIn(collectionName: "Users", sEmail: sEmail!, sPassword: sPassword!)
             }
             else {
                 self.continueForSignIn(collectionName: "NavyMembers", sEmail: sEmail!, sPassword: sPassword!)
             }
               
            }
        
    }
    
    func signIn(collectionName : String, sEmail : String, sPassword : String){
        self.ProgressHUDShow(text: "Sign In...")
        Auth.auth().signIn(withEmail: sEmail, password: sPassword) { (auth, error) in
            self.ProgressHUDHide()
            if error == nil {
              
                if let user = Auth.auth().currentUser {
                    if user.uid == "BIfLoGIMIqe10WM6T1YaaSgFHth1" {
                        self.beRootScreen(mIdentifier: Constants.StroyBoard.adminTabBarViewController)
                    }
                    else {
                      
                        self.getRoyalUserData(collectionName: collectionName, uid: Auth.auth().currentUser!.uid, showProgress: true)
                        
                    }
                }
            }
            
            else {
               
                self.showError(error!.localizedDescription)
            }
        }
    }
    
    func continueForSignIn(collectionName : String, sEmail : String, sPassword : String){
        ProgressHUDShow(text: "Wait...")
        
       
        Firestore.firestore().collection(collectionName).whereField("email", isEqualTo: sEmail).getDocuments { snapshot, error in
            self.ProgressHUDHide()
            
            if sEmail.lowercased() == "admin@adf.com" {
                self.signIn(collectionName: collectionName, sEmail: sEmail, sPassword: sPassword)
                
            }
            else {
                if let snapshot = snapshot, !snapshot.isEmpty {
                    self.signIn(collectionName: collectionName, sEmail: sEmail, sPassword: sPassword)
                }
                else {
                    
                    
                    if self.accountType == .PREJOINER {
                        self.showMessage(title: "PREJOINER", message: "No pre-joiner account found for \(sEmail). Please create new accont.", shouldDismiss: false)
                    }
                    else {
                        self.showMessage(title: "NAVY", message: "No navy member account found for \(sEmail). Please create new accont.", shouldDismiss: false)
                    }
                    
                }
            }
        
            
       
        }
        
        
    }
}
extension RoyalLoginViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
}
