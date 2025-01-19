//
//  CreateCategoryViewController.swift
//  Adf Ready
//
//  Created by Vijay Rathore on 20/11/24.
//

//
//  CreateCategoryViewController.swift
//  Royal Australian Navy
//
//  Created by Vijay Rathore on 27/10/23.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class CreateCategoryViewController : UIViewController {
    
   
    @IBOutlet weak var backView: UIImageView!
    @IBOutlet weak var createBtn: UIButton!

   
    @IBOutlet weak var isItGymCategoryTF: UITextField!
    
 
    @IBOutlet weak var titleTF: UITextField!
    
   
    @IBOutlet weak var descTF: UITextView!
    
    let placeholderText = "Description"
    
    var isImageChanged = false
    var type : String?
    
   
    var catId : String?
    
    
    
  
    override func viewDidLoad() {
        
        guard type != nil else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        
        descTF.textColor = UIColor.lightGray
        descTF.text = placeholderText
        
        descTF.layer.cornerRadius = 8
        descTF.delegate = self
        
        titleTF.delegate = self
    
       
        createBtn.layer.cornerRadius = 8
        
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
        
       
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
    
    
    
    
    @IBAction func createBtnClicked(_ sender: Any) {
        let cat_title = titleTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let cat_desc = descTF.text.trimmingCharacters(in: .whitespacesAndNewlines)
      
        let isItGym = isItGymCategoryTF.text
        
        
        var id = ""
        
        if let catId = catId, !catId.isEmpty {
            id = Firestore.firestore().collection(type!).document(catId).collection("SubWorkouts").document().documentID
        }
        else {
            id = Firestore.firestore().collection(type!).document().documentID
        }
       
        
        
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
        
        let catModel = CategoryModel()
       
        catModel.title = categoryName
        catModel.desc = categoryDesc
        catModel.id = id
        catModel.orderIndex = 0
        catModel.isItGymCategory = isItGym
        
        
        if isItGym {
            
            let categoryIds = ["gymcat1", "gymcat2", "gymcat3", "gymcat4", "gymcat5", "gymcat6", "gymcat7"]
            let categoryTitle = "Category Name"

            for categoryId in categoryIds {
                let categoryModel = CategoryModel()
                categoryModel.id = categoryId
                categoryModel.title = categoryTitle
                
                try? FirebaseStoreManager.db
                    .collection(self.type!)
                    .document(catModel.id!)
                    .collection("SubWorkouts")
                    .document(categoryId)
                    .setData(from: categoryModel)
            }
            
        }
        
        var docRef : DocumentReference!
        
        if let catId = catId, !catId.isEmpty {
            
            docRef = Firestore.firestore().collection(type!).document(catId).collection("SubWorkouts").document(id)
        }
        else{
            
             docRef = Firestore.firestore().collection(type!).document(id)
        }
      
      
        
        try? docRef.setData(from: catModel) { error in
            self.ProgressHUDHide()
            if error == nil {
                self.showToast(message: "Added")
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





extension CreateCategoryViewController :  UITextFieldDelegate, UITextViewDelegate {
    
    
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
