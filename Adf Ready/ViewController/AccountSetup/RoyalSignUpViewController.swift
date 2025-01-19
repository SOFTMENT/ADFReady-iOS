//
//  SignUpViewController.swift
//  Royal Australian Navy
//
//  Created by Vijay Rathore on 01/11/23.
//

import UIKit
import FirebaseAuth
import Firebase

class RoyalSignUpViewController : UIViewController {
    
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!

    @IBOutlet weak var signUpBtn: UIButton!
    
 
    @IBOutlet weak var loginBtn: UILabel!
    @IBOutlet weak var backView: UIImageView!
    
    @IBOutlet weak var signUpLbl: UILabel!
    var accountType : ACCOUNT_TYPE?
    @IBOutlet weak var subHeadingLbl: UILabel!
    
    override func viewDidLoad() {
        guard accountType != nil else {
            
            DispatchQueue.main.async {
                self.logout()
                
            }
            return
            
        }
        
        if accountType == .PREJOINER {
            signUpLbl.text = "Pre-Joiner Sign Up"
            
        }
        else {
            subHeadingLbl.text = "Enter your pmkeys, email & password below"
            signUpLbl.text = "Navy Member Sign Up"
            nameTF.placeholder = "Pmkeys"
        }
        nameTF.delegate = self
        emailTF.delegate = self
        passwordTF.delegate = self
        
        signUpBtn.layer.cornerRadius = 8
        
        loginBtn.isUserInteractionEnabled = true
        loginBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(loginBtnClicked)))
        
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnClicked)))
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked)))
    }
    
    @objc func backBtnClicked(){
        self.dismiss(animated: true)
    }
    @IBAction func signupClicked(_ sender: Any) {
        let sName = nameTF.text
        let sEmail = emailTF.text
        let sPassword = passwordTF.text
        
        if sName == "" {
            self.showToast(message: "Enter Name")
        }
        else if sEmail == "" {
            self.showToast(message: "Enter Email")
        }
        else if sPassword == "" {
            self.showToast(message: "Enter Password")
        }
        else {
            self.ProgressHUDShow(text: "")
            Auth.auth().createUser(withEmail: sEmail!, password: sPassword!) { auth, error in
               
                if let error = error {
                    self.ProgressHUDHide()
                    self.showError(error.localizedDescription)
                }
                else {
                    let userModel = UserModel()
                    userModel.uid = auth!.user.uid
                    userModel.email = sEmail
                    userModel.fullName = sName
                    userModel.activeAccount = false
                    userModel.date = Date()
                    if self.accountType == .PREJOINER {
                        self.addUserOnFirebase(userModel: userModel, collectionName: "Users")
                    }
                    else {
                        self.addUserOnFirebase(userModel: userModel,collectionName: "NavyMembers")
                    }
                  
                }
            }
        }
    }
    
    
    func addUserOnFirebase(userModel : UserModel,collectionName : String){
        
        try? Firestore.firestore().collection(collectionName).document(userModel.uid!).setData(from: userModel) { error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error.localizedDescription)
            }
            else {
                self.getRoyalUserData(collectionName: collectionName, uid: userModel.uid!, showProgress: true)
            }
        }
    }
    
    @objc func viewClicked(){
        self.view.endEditing(true)
    }
    
    @objc func loginBtnClicked(){
        self.dismiss(animated: true)
    }
    
   
    
}
extension RoyalSignUpViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
}
