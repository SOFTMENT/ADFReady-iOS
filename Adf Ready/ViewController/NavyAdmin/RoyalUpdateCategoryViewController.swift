//
//  UpdateCategoryViewController.swift
//  Royal Australian Navy
//
//  Created by Vijay Rathore on 27/10/23.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class RoyalUpdateCategoryViewController : UIViewController {
    
   
    @IBOutlet weak var backView: UIImageView!
    @IBOutlet weak var createBtn: UIButton!
    @IBOutlet weak var deleteCat: UIImageView!
    @IBOutlet weak var cat_img: UIImageView!
    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var descTF: UITextView!
    
    let placeholderText = "Description"
    
    var isImageChanged = false
    var type : String?
    var catId : String?
    var catModel : CategoryModel?
    var accountType : ACCOUNT_TYPE?
    override func viewDidLoad() {
        
        guard type != nil, let catModel = catModel else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }
        
        if let path = catModel.image, !path.isEmpty {
            cat_img.sd_setImage(with: URL(string: path), placeholderImage: UIImage(named: "placeholder"))
        }
        
        
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        
    
        descTF.text = placeholderText
        descTF.layer.cornerRadius = 8
        descTF.delegate = self
       
  
       
        titleTF.text = catModel.title ?? ""
        descTF.text = catModel.desc ?? placeholderText
        
        titleTF.delegate = self
    
        cat_img.layer.cornerRadius = 8
        createBtn.layer.cornerRadius = 8
        
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
        
        deleteCat.isUserInteractionEnabled = true
        deleteCat.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(deleteCatClicked)))
        
        //TapToChangeImage
        cat_img.isUserInteractionEnabled = true
        cat_img.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeImages)))
    
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
    
    @objc func changeImages() {
        
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = .photoLibrary
        image.allowsEditing = true
        self.present(image,animated: true)
    }
    
    
    @IBAction func updateBtnClicked(_ sender: Any) {
        let cat_title = titleTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let cat_desc = descTF.text.trimmingCharacters(in: .whitespacesAndNewlines)
      
        
        var id = ""
       
        id = catModel!.id ?? "123"
        
        
        
            if cat_title != "" {
                if cat_desc != "" {
                    
                    ProgressHUDShow(text: "Updating...")
            
                    if isImageChanged {
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
                        self.uploadDetailsOnDatabase(id : id,downloadUrl: self.catModel!.image!, categoryName: cat_title!, categoryDesc: cat_desc)
                    }
                   
                }
                else {
                    showToast(message: "Please enter description")
                }
            }
            else {
                showToast(message: "Please enter title")
            }
       
    }
    
    
    func uploadDetailsOnDatabase(id : String,downloadUrl : String ,categoryName : String , categoryDesc : String) {
        
       
        self.catModel!.image = downloadUrl
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

extension RoyalUpdateCategoryViewController : UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
            isImageChanged = true
            cat_img.image = editedImage
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
}



extension RoyalUpdateCategoryViewController :  UITextFieldDelegate, UITextViewDelegate {
    
    
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
