//
//  AdminEntryViewController.swift
//  Adf Ready
//
//  Created by Vijay Rathore on 20/11/24.
//

import UIKit

class AdminEntryViewController : UIViewController {
    
    
    @IBOutlet weak var trackMembersView: RoundedButton!
    @IBOutlet weak var addInformationBtn: RoundedButton!
    @IBOutlet weak var addWorkoutBtn: RoundedButton!
    @IBOutlet weak var userSelectionTF: CustomTextField!
    var service = ""
    override func viewDidLoad() {
        view.isUserInteractionEnabled = true
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        userSelectionTF.delegate = self
        userSelectionTF.isUserInteractionEnabled = true
        userSelectionTF.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showServiceSelection)))
        userSelectionTF.setRightIcons(icon: UIImage(named: "down-arrow")!)
        
        trackMembersView.isUserInteractionEnabled = true
        trackMembersView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(trackMembersClicked)))
    }
    
    
    @objc func trackMembersClicked() {
        self.performSegue(withIdentifier: "trackSeg", sender: nil)
    }
    
    @IBAction func userPanelClicked(_ sender: Any) {
        showServiceSelectionUser()
      
    }
    
     func showServiceSelectionUser() {
          let alertController = UIAlertController(title: "Select Service", message: nil, preferredStyle: .actionSheet)
          
        for state in Constants.services {
              let action = UIAlertAction(title: state, style: .default) { _ in
                  UserModel.data!.service = state
                  self.beRootScreen(mIdentifier: Constants.StroyBoard.tabBarViewController)
              }
              alertController.addAction(action)
          }
          
          // Add a cancel option
          let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
          alertController.addAction(cancelAction)
          
          
          present(alertController, animated: true, completion: nil)
      }
    
    @IBAction func logoutClicked(_ sender: Any) {
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            self.logout()
        }))
                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    @IBAction func managePFAClicked(_ sender: Any) {
        performSegue(withIdentifier: "managePFASeg", sender: nil)
    }
    @objc func showServiceSelection() {
          let alertController = UIAlertController(title: "Select Service", message: nil, preferredStyle: .actionSheet)
          
        for state in Constants.services {
              let action = UIAlertAction(title: state, style: .default) { _ in
                  self.userSelectionTF.text = state
                  self.setUserType(state)
              }
              alertController.addAction(action)
          }
          
          // Add a cancel option
          let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
          alertController.addAction(cancelAction)
          
          // Present the alert controller as an action sheet
          if let popoverController = alertController.popoverPresentationController {
              popoverController.sourceView =  userSelectionTF
              popoverController.sourceRect = userSelectionTF.bounds
          }
          present(alertController, animated: true, completion: nil)
      }
    
    
    @IBAction func addInformationClicked(_ sender: Any) {
        performSegue(withIdentifier: "infoSeg", sender: nil)
    }
    @IBAction func addWorkoutClicked(_ sender: Any) {
        performSegue(withIdentifier: "workoutSeg", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "infoSeg" {
            if let VC = segue.destination as? AdminInformationsCategoryViewController {
                VC.service = self.service
            }
        }
        else if segue.identifier == "workoutSeg" {
            if let VC = segue.destination as? AdminWorkoutCategoryViewController {
                VC.service = self.service
            }
        }
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }

    func setUserType(_ service : String) {
        
        self.addWorkoutBtn.isHidden = false
        self.addInformationBtn.isHidden = false
        self.addWorkoutBtn.setTitle("Add Workout - \(service)", for: .normal)
        self.addInformationBtn.setTitle("Add Information - \(service)", for: .normal)
       
        self.service = service
    }

}
extension AdminEntryViewController : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}
