//
//  SignInViewController.swift
//  Adf Ready
//
//  Created by Vijay Rathore on 15/11/24.
//

import UIKit

class SignInViewController : UIViewController {
    
    @IBOutlet weak var createNewAccountLbl: UILabel!
    @IBOutlet weak var backView: UIImageView!
    
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var forgotPasswordLbl: UILabel!
    
    
    override func viewDidLoad() {
        
        forgotPasswordLbl.isUserInteractionEnabled = true
        forgotPasswordLbl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(forgotPasswordClicked)))
        
        createNewAccountLbl.isUserInteractionEnabled = true
        createNewAccountLbl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(createNewAccountClicked)))
        
        emailTF.delegate = self
        passwordTF.delegate = self
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
    }
    
    @objc func backViewClicked() {
        self.dismiss(animated: true)
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    @objc func createNewAccountClicked() {
        performSegue(withIdentifier: "signUpSeg", sender: nil)
    }
    
    @objc func forgotPasswordClicked() {
        guard let sEmail = emailTF.text, !sEmail.isEmpty else {
            self.showToast(message: "Enter email address.")
            return
        }
        self.ProgressHUDShow(text: "Resetting...")
        FirebaseStoreManager.auth.sendPasswordReset(withEmail: sEmail) { error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error.localizedDescription)
            }
            else {
                self.showMessage(title: "Password Reset", message: "We have sent password reset link to your mail address.", shouldDismiss: false)
            }
        }
        
    }
    
    @IBAction func loginBtnClicked(_ sender: Any) {
        guard let sEmail = emailTF.text, !sEmail.isEmpty else {
            self.showToast(message: "Enter email address.")
            return
        }
        guard let sPassword = passwordTF.text, !sPassword.isEmpty else {
            self.showToast(message: "Enter password.")
            return
        }
        self.ProgressHUDShow(text: "Logging in...")
        FirebaseStoreManager.auth.signIn(withEmail: sEmail, password: sPassword) { result, error in
            self.ProgressHUDHide()
            if error != nil {
                self.showError("Incorrect email or password.")
            }
            else {
                self.getUserData(uid: result!.user.uid, showProgress: false)
            }
        }
    }
    
}


extension SignInViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
}
