//
//  UserTypeViewController.swift
//  Adf Ready
//
//  Created by Vijay Rathore on 15/11/24.
//

import UIKit

class UserTypeViewController : UIViewController {
    
    @IBOutlet weak var helloNameLbl: UILabel!
    
   
    @IBOutlet weak var serviceTF: CustomTextField!
    override func viewDidLoad() {
        
        guard let userModel = UserModel.data else {
            
            DispatchQueue.main.async {
                self.logout()
            }
            return
        }
        
        helloNameLbl.text = "Hello👋, \(userModel.fullName!.capitalized)"
        
        
        serviceTF.delegate = self
        serviceTF.isUserInteractionEnabled = true
        serviceTF.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showServiceSelection)))
        
        view.isUserInteractionEnabled = true
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }
    

    @IBAction func submitBtnClicked(_ sender: Any) {
        guard let sService = serviceTF.text, !sService.isEmpty else {
            self.showToast(message: "Please select service")
            return
        }
        
        self.setUserType(sService)
    }
    
    @objc func showServiceSelection() {
          let alertController = UIAlertController(title: "Select Service", message: nil, preferredStyle: .actionSheet)
          
        for state in Constants.services {
              let action = UIAlertAction(title: state, style: .default) { _ in
                  self.serviceTF.text = state
                
              }
              alertController.addAction(action)
          }
          
          // Add a cancel option
          let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
          alertController.addAction(cancelAction)
          
          // Present the alert controller as an action sheet
          if let popoverController = alertController.popoverPresentationController {
              popoverController.sourceView =  serviceTF
              popoverController.sourceRect = serviceTF.bounds
          }
          present(alertController, animated: true, completion: nil)
      }
    @objc func hideKeyboard() {
        view.endEditing(true)
    }

    func setUserType(_ service : String) {
        self.ProgressHUDShow(text: "")
        UserModel.data?.service = service
        FirebaseStoreManager.db.collection("Users").document(FirebaseStoreManager.auth.currentUser!.uid)
            .setData(["service":service], merge: true) { error in
                self.ProgressHUDHide()
                if let error = error {
                    self.showError(error.localizedDescription)
                }
                else {
                    self.beRootScreen(mIdentifier: Constants.StroyBoard.tabBarViewController)
                }
                
            }
            
        }
    
}


extension UserTypeViewController : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}
