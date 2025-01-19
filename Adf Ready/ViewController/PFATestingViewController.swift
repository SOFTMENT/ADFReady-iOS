//
//  PFATestingViewController.swift
//  Adf Ready
//
//  Created by Vijay Rathore on 16/11/24.
//

import UIKit
import FirebaseFirestoreInternal

class PFATestingViewController : UIViewController {
   
    @IBOutlet weak var submitBtn: RoundedButton!
    
    @IBOutlet weak var beepTF: CustomTextField!
    @IBOutlet weak var situpTF: CustomTextField!
    @IBOutlet weak var pushUpTF: CustomTextField!
    @IBOutlet weak var beepView: RoundedView!
    @IBOutlet weak var sitUpView: RoundedView!
    @IBOutlet weak var pushUpTestView: RoundedView!
    var type : String = ""
    override func viewDidLoad() {
       
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        checkIfDataSubmittedForToday(userId: FirebaseStoreManager.auth.currentUser!.uid) { alreadySubmitted in
            if alreadySubmitted {
                self.submitBtn.isEnabled = false
                self.submitBtn.setTitle("Submitted", for: .disabled)
                self.submitBtn.backgroundColor = .lightGray
                
            }
          
        }
        self.beepTF.delegate = self
        self.situpTF.delegate = self
        self.pushUpTF.delegate = self
        
        pushUpTestView.isUserInteractionEnabled = true
        pushUpTestView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pushClicked)))
        
        sitUpView.isUserInteractionEnabled = true
        sitUpView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sitClicked)))
        
        beepView.isUserInteractionEnabled = true
        beepView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(beepClicked)))
        
    }
    @objc func pushClicked(){
        self.ProgressHUDShow(text: "")
        self.getPFA(type: "Push") { content in
            
            if let content = content {
                self.getPFAVideos(type: "Push") { contents in
                    self.ProgressHUDHide()
                    content.multiVideoModels = contents ?? []
                    self.type = "Push"
                    self.performSegue(withIdentifier: "viewPFASeg", sender: content)
                }
               
            }
            
        }
    }
    
    @objc func sitClicked(){
        self.getPFA(type: "Sit") { content in
            if let content = content {
                self.getPFAVideos(type: "Sit") { contents in
                    self.ProgressHUDHide()
                    content.multiVideoModels = contents ?? []
                    self.type = "Sit"
                    self.performSegue(withIdentifier: "viewPFASeg", sender: content)
                }
               
            }
           
        }

    }
    
    @objc func beepClicked(){
        self.getPFA(type: "Beep") { content in
            if let content = content {
                self.getPFAVideos(type: "Beep") { contents in
                    self.ProgressHUDHide()
                    content.multiVideoModels = contents ?? []
                    self.type = "Beep"
                    self.performSegue(withIdentifier: "viewPFASeg", sender: content)
                }
               
            }
            
        }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewPFASeg" {
            if let VC = segue.destination as? ViewContentViewController {
                if let index = sender as? ContentModel {
                    
                    var contentModels = Array<ContentModel>()
                    contentModels.append(index)
                    VC.contentModels = contentModels
                    VC.position = 0
                    VC.type = self.type
                   
                }
            }
        }
    }
    
    @objc func hideKeyboard(){
     
        self.view.endEditing(true)
        
     

    }
    
   
    func checkIfDataSubmittedForToday(userId: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let today = getTodayDateString()

        let dailyEntryRef = db.collection("Users")
            .document(userId)
            .collection("pfa")
            .document(today)

        dailyEntryRef.getDocument { document, error in
            if let error = error {
                print("Error checking today's submission: \(error.localizedDescription)")
                completion(false)
                return
            }

            // Document exists if `document.exists` is true
            if document?.exists == true {
                print("Data already submitted for today.")
                completion(true)
            } else {
                print("No data submitted for today.")
                completion(false)
            }
        }
    }

    
    
    @IBAction func submitClicked(_ sender: Any) {
        guard let sPushups = pushUpTF.text, !sPushups.isEmpty, let iPushups = Int(sPushups),iPushups >= 0 else {
            self.showToast(message: "Enter Push ups")
            return
        }
        guard let sSitups = situpTF.text, !sSitups.isEmpty, let iSitups = Int(sSitups),iSitups >= 0 else {
            self.showToast(message: "Enter Sit ups")
            return
        }
        guard let sBeep = beepTF.text, !sBeep.isEmpty, let iBeep = Double(sBeep),iBeep >= 0 else {
            self.showToast(message: "Enter Beep")
            return
        }
        
        self.saveDailyFitnessData(userId: FirebaseStoreManager.auth.currentUser!.uid, date: getTodayDateString(), pushUps: iPushups, pullUps: iSitups, beepTest: iBeep)
        
    }
    
    func getTodayDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    func saveDailyFitnessData(userId: String, date: String, pushUps: Int, pullUps: Int, beepTest: Double) {
      
        self.submitBtn.isEnabled = false
        self.submitBtn.setTitle("Submitted", for: .disabled)
        self.submitBtn.backgroundColor = .lightGray
        
        self.ProgressHUDShow(text: "Saving...")
        let db = FirebaseStoreManager.db
        let dailyEntryRef = db.collection("Users").document(userId).collection("pfa").document(date)
        
        let data: [String: Any] = [
            "pushUps": pushUps,
            "sitUps": pullUps,
            "beepTest": beepTest,
            "submittedAt": Timestamp(date: Date()) // Use current timestamp
        ]
        
        dailyEntryRef.setData(data) { error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError("Error saving daily fitness data: \(error.localizedDescription)")
            } else {
                self.showToast(message: "Daily fitness data saved successfully!")
                
            }
        }
    }
    
    
}

extension PFATestingViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    // UITextFieldDelegate method to enforce limit
       func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
           if textField == self.pushUpTF || textField == self.situpTF {
               // Get the current text
               let currentText = textField.text ?? ""

               // Create the updated text
               guard let stringRange = Range(range, in: currentText) else { return false }
               let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

               // Allow only numeric input and check if it's <= 100
               if let number = Int(updatedText), number <= 100 {
                   return true // Allow change
               }

               if updatedText.isEmpty { // Allow backspace
                   return true
               }

               return false // Reject change
           }
           return true
       }
}
