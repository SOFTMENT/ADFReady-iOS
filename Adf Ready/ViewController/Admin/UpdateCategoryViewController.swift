//
//  UpdateCategoryViewController.swift
//  Adf Ready
//
//  Created by Vijay Rathore on 20/11/24.
//

//
//  UpdateCategoryViewController.swift
//  Royal Australian Navy
//
//  Created by Vijay Rathore on 27/10/23.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class UpdateCategoryViewController : UIViewController {
    
   
    @IBOutlet weak var backView: UIImageView!
    @IBOutlet weak var createBtn: UIButton!
    @IBOutlet weak var deleteCat: UIImageView!
    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var descTF: UITextView!
    
    let placeholderText = "Description"
    
    @IBOutlet weak var isItGymCategoryTF: UITextField!
    var isImageChanged = false
    var type : String?
    var catId : String?
    var catModel : CategoryModel?
  
    override func viewDidLoad() {
        
        guard type != nil, let catModel = catModel else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }
        
      
        
        
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        
    
        descTF.text = placeholderText
        descTF.layer.cornerRadius = 8
        descTF.delegate = self
       
      
       
        titleTF.text = catModel.title ?? ""
        descTF.text = catModel.desc ?? placeholderText
        isItGymCategoryTF.text = (catModel.isItGymCategory ?? false) == true ? "Yes" : "No"
        
        titleTF.delegate = self
    
        
        createBtn.layer.cornerRadius = 8
        
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
        
        deleteCat.isUserInteractionEnabled = true
        deleteCat.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(deleteCatClicked)))
        
        if type!.contains("Workouts") {
            isItGymCategoryTF.isHidden = false
        }
     
        isItGymCategoryTF.delegate = self
        isItGymCategoryTF.setRightIcons(icon: UIImage(named: "down-arrow")!)
        isItGymCategoryTF.isUserInteractionEnabled = true
        isItGymCategoryTF.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showSelction)))
    }
    @objc func showSelction(){
        let alert = UIAlertController(title: "Is it a Gym Category?", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.isItGymCategoryTF.text = "Yes"
        }))
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { action in
            self.isItGymCategoryTF.text = "No"
        }))
        present(alert, animated: true)
    }
    
    
    @objc func deleteCatClicked(){
        let alert = UIAlertController(title: "Delete", message: "Are you sure you want to delete this category?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
            
        

            
            self.ProgressHUDShow(text: "Deleting...")
            
            let storage =  Storage.storage().reference().child("Categories").child(self.catModel!.id!).child("\(self.catModel!.id!).png")
            storage.delete { error in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
            
            if let catId = self.catId, !catId.isEmpty {
                Firestore.firestore().collection(self.type!).document(catId).collection("SubWorkouts").document(self.catModel!.id!).delete { error in
                    self.ProgressHUDHide()
                    if let error = error {
                        self.showError(error.localizedDescription)
                    }
                    else {
                        self.showToast(message: "Deleted")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                            self.dismiss(animated: true)
                        }
                    }
                }
            }
            else {
                Firestore.firestore().collection(self.type!).document(self.catModel!.id!).delete { error in
                    self.ProgressHUDHide()
                    if let error = error {
                        self.showError(error.localizedDescription)
                    }
                    else {
                        self.showToast(message: "Deleted")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                            self.dismiss(animated: true)
                        }
                    }
                }
            }
            
          
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
   
    
    
    @IBAction func updateBtnClicked(_ sender: Any) {
        let cat_title = titleTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let cat_desc = descTF.text.trimmingCharacters(in: .whitespacesAndNewlines)
      
        let isItGym = isItGymCategoryTF.text
        var id = ""
       
        id = catModel!.id ?? "123"
        
        
        if cat_title != "" {
            if cat_desc != "" {
                if !self.type!.contains("Workouts") || isItGym != "" {
                    ProgressHUDShow(text: "Creating...")
                    
                    
                    self.uploadDetailsOnDatabase(id : id, categoryName: cat_title!, categoryDesc: cat_desc, isItGym: isItGym == "Yes" ? true : false)
                    
                    
                }
                
                else {
                    showToast(message: "Select is it gym category")
                }
                
                
            }
                else {
                    showToast(message: "Please enter desc")
                }
            }
            else {
                showToast(message: "Please enter title")
            }
        
       
    }
    
    
    func uploadDetailsOnDatabase(id : String,categoryName : String , categoryDesc : String, isItGym : Bool) {
        
       
      
        self.catModel!.title = categoryName
        self.catModel!.desc = categoryDesc
      
        
        var docRef : DocumentReference!
        
      
       
        
        if let catId = catId, !catId.isEmpty {
            
            docRef = Firestore.firestore().collection(type!).document(catId).collection("SubWorkouts").document(id)
        }
        else{
            
             docRef = Firestore.firestore().collection(type!).document(id)
        }
       
        
        try? docRef.setData(from: catModel,merge: true) { error in
            self.ProgressHUDHide()
            if error == nil {
                self.showToast(message: "Updated")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    self.dismiss(animated: true)
                }
            }
            else {
                self.showError(error!.localizedDescription)
            }
        }
    }
    
    
    
    
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    @objc func backViewClicked(){
        self.dismiss(animated: true)
    }
    

}




extension UpdateCategoryViewController :  UITextFieldDelegate, UITextViewDelegate {
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true;
    }
  
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.text == placeholderText {
            textView.textColor = UIColor.black
            textView.text = ""
        }
        return true
    }
    

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.textColor = UIColor.lightGray
            textView.text = placeholderText
        }
    }
    
}
