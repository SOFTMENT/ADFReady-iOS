//
//  CreateCategoryViewController.swift
//  Royal Australian Navy
//
//  Created by Vijay Rathore on 27/10/23.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class RoyalCreateCategoryViewController : UIViewController {
    
   
    @IBOutlet weak var backView: UIImageView!
    @IBOutlet weak var createBtn: UIButton!

    @IBOutlet weak var cat_img: UIImageView!
    
 
    @IBOutlet weak var titleTF: UITextField!
    
   
    @IBOutlet weak var descTF: UITextView!
    
    let placeholderText = "Description"
    
    var isImageChanged = false
    var type : String?
    
    var accountType : ACCOUNT_TYPE?
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
    
        cat_img.layer.cornerRadius = 8
        createBtn.layer.cornerRadius = 8
        
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
        
        //TapToChangeImage
        cat_img.isUserInteractionEnabled = true
        cat_img.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeImages)))
    
    }
    
    @objc func changeImages() {
        
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = .photoLibrary
        image.allowsEditing = true
        self.present(image,animated: true)
        
    }
    
    
    @IBAction func createBtnClicked(_ sender: Any) {
        let cat_title = titleTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let cat_desc = descTF.text.trimmingCharacters(in: .whitespacesAndNewlines)
      
        
        
        
        var id = ""
        
        if let catId = catId, !catId.isEmpty {
            id = Firestore.firestore().collection(type!).document(catId).collection("SubWorkouts").document().documentID
        }
        else {
            id = Firestore.firestore().collection(type!).document().documentID
        }
       
        
        if isImageChanged {
            if cat_title != "" {
                if cat_desc != "" {
                    
                    ProgressHUDShow(text: "Creating...")
            
                    
                    self.uploadImageOnFirebase(id: id) { (downloadUrl) in
                        
                        if downloadUrl != "" {
                            self.uploadDetailsOnDatabase(id : id,downloadUrl: downloadUrl, categoryName: cat_title!, categoryDesc: cat_desc)
                        }
                        else {
                            self.showToast(message: "Image Upload Failed")
                            self.ProgressHUDHide()
                        }
                       
                
                        
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
        else {
            showToast(message: "Please add image")
        }
    }
    
    func uploadDetailsOnDatabase(id : String,downloadUrl : String ,categoryName : String , categoryDesc : String) {
        
        let catModel = CategoryModel()
        catModel.image = downloadUrl
        catModel.title = categoryName
        catModel.desc = categoryDesc
        catModel.id = id
        catModel.orderIndex = 0
        
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
    
    
    
    func uploadImageOnFirebase( id : String,completion : @escaping (String) -> Void ) {
        
        
        var storage : StorageReference!
        
        if let catId = catId {
            storage = Storage.storage().reference().child("Categories").child(catId).child("SubCateogry").child("\(id).png")
        }
        else {
            storage = Storage.storage().reference().child("Categories").child(id).child("\(id).png")
        }
      
        
        
        
        var downloadUrl = ""
        let uploadData = (self.cat_img.image?.jpegData(compressionQuality: 0.4))!
    
        storage.putData(uploadData, metadata: nil) { (metadata, error) in
            
            if error == nil {
                storage.downloadURL { (url, error) in
                    if error == nil {
                        downloadUrl = url!.absoluteString
                    }
                    completion(downloadUrl)
                    
            
                    
                }
            }
            else {
                completion(downloadUrl)
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

extension RoyalCreateCategoryViewController : UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
            isImageChanged = true
            cat_img.image = editedImage
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
}



extension RoyalCreateCategoryViewController :  UITextFieldDelegate, UITextViewDelegate {
    
    
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
