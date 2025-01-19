//
//  AdminGymWorkoutViewController.swift
//  Adf Ready
//
//  Created by Vijay Rathore on 02/12/24.
//

import UIKit

class AdminGymWorkoutViewController : UIViewController {
    var type : String?
    var cName : String?
    var catId : String?
    var subId : String?
    
    @IBOutlet weak var backView: UIImageView!
    @IBOutlet weak var catName: UILabel!
    
    
    @IBOutlet weak var cat1View: RoundedView!
    @IBOutlet weak var cat2View: RoundedView!
    @IBOutlet weak var cat3View: RoundedView!
    @IBOutlet weak var cat4View: RoundedView!
    @IBOutlet weak var cat5View: RoundedView!
    @IBOutlet weak var cat6View: RoundedView!
    @IBOutlet weak var cat7View: RoundedView!
    @IBOutlet weak var cat1Title: UILabel!
    @IBOutlet weak var cat2Title: UILabel!
    @IBOutlet weak var cat3Title: UILabel!
    @IBOutlet weak var cat4Title: UILabel!
    @IBOutlet weak var cat5Title: UILabel!
    @IBOutlet weak var cat6Title: UILabel!
    @IBOutlet weak var cat7Title: UILabel!
    @IBOutlet weak var edit1: UIImageView!
    @IBOutlet weak var edit2: UIImageView!
    @IBOutlet weak var edit3: UIImageView!
    @IBOutlet weak var edit4: UIImageView!
    @IBOutlet weak var edit5: UIImageView!
    @IBOutlet weak var edit6: UIImageView!
    @IBOutlet weak var edit7: UIImageView!
    
    var categories : [CategoryModel] = []
    
    override func viewDidLoad() {
        
        guard let type = type,
        let cName = cName,
              let catId = catId else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }
        catName.text = cName
        
      
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnClicked)))
        
        let categories = [
            (view: cat1View, id: "gymcat1"),
            (view: cat2View, id: "gymcat2"),
            (view: cat3View, id: "gymcat3"),
            (view: cat4View, id: "gymcat4"),
            (view: cat5View, id: "gymcat5"),
            (view: cat6View, id: "gymcat6"),
            (view: cat7View, id: "gymcat7")
        ]

        for category in categories {
            if let view = category.view { // Safely unwrap the optional view
                view.isUserInteractionEnabled = true
                let gesture = MyTapGesture(target: self, action: #selector(catViewClicked))
                gesture.id = category.id
                view.addGestureRecognizer(gesture)
            } else {
                print("Warning: \(category.id) view is nil")
            }
        }

        let editCategories = [
            (view: edit1, id: 0),
            (view: edit2, id: 1),
            (view: edit3, id: 2),
            (view: edit4, id: 3),
            (view: edit5, id: 4),
            (view: edit6, id: 5),
            (view: edit7, id: 6)
        ]

        for category in editCategories {
            if let view = category.view { // Safely unwrap the optional view
                view.isUserInteractionEnabled = true
                let gesture = MyTapGesture(target: self, action: #selector(editBtnClicked))
                gesture.index = category.id
                view.addGestureRecognizer(gesture)
            } else {
                print("Warning: \(category.id) view is nil")
            }
        }

        
        cat2View.isUserInteractionEnabled = true
        
        
        self.ProgressHUDShow(text: "")
        self.getAllGymCategory(type: type, catId: catId) { categories in
            self.ProgressHUDHide()
            if let categories = categories, categories.count > 0 {
                self.categories.append(contentsOf: categories)
                for subCat in categories {
                    if subCat.id == "gymcat1" {
                        self.cat1Title.text = subCat.title ?? "Category Title"
                    }
                    else if subCat.id == "gymcat2" {
                        self.cat2Title.text = subCat.title ?? "Category Title"
                    }
                    else if subCat.id == "gymcat3" {
                        self.cat3Title.text = subCat.title ?? "Category Title"
                    }
                    else if subCat.id == "gymcat4" {
                        self.cat4Title.text = subCat.title ?? "Category Title"
                    }
                    else if subCat.id == "gymcat5" {
                        self.cat5Title.text = subCat.title ?? "Category Title"
                    }
                    else if subCat.id == "gymcat6" {
                        self.cat6Title.text = subCat.title ?? "Category Title"
                    }
                    else if subCat.id == "gymcat7" {
                        self.cat7Title.text = subCat.title ?? "Category Title"
                    }
                }
            }
        }
    }
    
    
    @objc func editBtnClicked(value : MyTapGesture){
        
        let categoryModel = self.categories[value.index]
        
        // Create alert controller
           let alertController = UIAlertController(title: "Rename",
                                                   message: "Enter a new name:",
                                                   preferredStyle: .alert)
           
           // Add text field to alert
           alertController.addTextField { textField in
               textField.text = categoryModel.title ?? ""
           }
           
           // Add Rename button action
           let renameAction = UIAlertAction(title: "Rename", style: .default) { _ in
               // Get the text from the text field
               if let newName = alertController.textFields?.first?.text, !newName.isEmpty {
                   switch value.index {
                   case 0:
                       self.cat1Title.text = newName
                   case 1:
                       self.cat2Title.text = newName
                   case 2:
                       self.cat3Title.text = newName
                   case 3:
                       self.cat4Title.text = newName
                   case 4:
                       self.cat5Title.text = newName
                   case 5:
                       self.cat6Title.text = newName
                   case 6:
                       self.cat7Title.text = newName
                   default:
                       print("NOTHING")
                   }
                   self.categories[value.index].title = newName
                   self.renamedCategory(self.categories[value.index])
               } else {
                   self.showToast(message: "Enter a name")
               }
           }
           alertController.addAction(renameAction)
           
           // Add Cancel button action
           let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
           alertController.addAction(cancelAction)
           
        present(alertController, animated: true)
    }
    
    func renamedCategory(_ category: CategoryModel) {
        ProgressHUDShow(text: "Renaming...")
        FirebaseStoreManager.db.collection(self.type!).document(self.catId!).collection("SubWorkouts").document(category.id!).updateData(["title": category.title!]) { error in
            self.ProgressHUDHide()
            self.showToast(message: "Renamed successfully")
        }
    }
    
    @objc func catViewClicked(value : MyTapGesture){
        performSegue(withIdentifier: "subSeg", sender: value.id)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "subSeg" {
          
                 if let VC = segue.destination as? AdminSubCategoryViewController {
                     if let subCatId = sender as? String {
                    
                         print(subCatId)
                         
                         VC.catId = self.catId
                         VC.catName = self.cName
                         VC.subId = subCatId
                         VC.type = self.type
                     }
                 }
             
         }
    }
    
   
    @objc func backBtnClicked(){
        self.dismiss(animated: true)
    }
    
}
