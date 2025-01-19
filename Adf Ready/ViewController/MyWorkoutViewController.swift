//
//  MyWorkoutViewController.swift
//  Adf Ready
//
//  Created by Vijay Rathore on 26/11/24.
//



import UIKit
import SDWebImage
import FirebaseStorage
import Firebase


class MyWorkoutViewController : UIViewController {
    
    var type : String?
    var catName : String?
    var catId : String?
    var subId : String?
    @IBOutlet weak var backView: UIImageView!
    var categoryModels : Array<CategoryModel> = []
    let dayLabels = ["M", "T", "W", "T", "F", "S", "S"]

    @IBOutlet weak var catLbl: UILabel!
   
    
 
    @IBOutlet weak var tableView: UITableView!
    
  
    override func viewDidLoad() {
        
      
        loadApp(type: type, catName: catName, catId: catId)
    }
    
    func loadApp(type : String?, catName : String?, catId : String?){
        guard let type = type,
        let catName = catName,
              let catId = catId else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }

        catLbl.text = catName
        
     
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnClicked)))
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        tableView.isEditing = true

        ProgressHUDShow(text: "")
        
     

           let userId = Auth.auth().currentUser?.uid ?? "defaultUser" // Replace with actual user identifier
           let preferencesRef = Firestore.firestore().collection("Users").document(userId).collection("Preferences").document(catId)
           
           preferencesRef.getDocument { snapshot, error in
               if let data = snapshot?.data(), let savedOrder = data["categoryOrder"] as? [String] {
                   self.getAllGymCategory(type: type, catId: catId) { categories in
                       self.ProgressHUDHide()
                       self.categoryModels.removeAll()
                       if let categories = categories {
                           // Reorder categories based on savedOrder
                           let orderedCategories = savedOrder.compactMap { id in
                               categories.first { $0.id == id }
                           }
                           let remainingCategories = categories.filter { !savedOrder.contains($0.id!) }
                           self.categoryModels = orderedCategories + remainingCategories
                       }
                       self.tableView.reloadData()
                   }
               } else {
                   self.getAllGymCategory(type: type, catId: catId) { categories in
                       self.ProgressHUDHide()
                       self.categoryModels.removeAll()
                       if let categories = categories {
                           self.categoryModels.append(contentsOf: categories)
                       }
                       self.tableView.reloadData()
                   }
               }
           }
        
    }
   
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
         if segue.identifier == "subCatSeg" {
            if let VC = segue.destination as? SubcategoryViewController  {
                if let category = sender as? CategoryModel {
                    VC.catId = self.catId!
                    VC.catName = category.title
                    VC.type = "\(UserModel.data!.service!)Workouts"
                    VC.subId = category.id
                    
                }
            }
        }
    }
    
    @objc func backBtnClicked(){
        self.dismiss(animated: true)
    }
    
    @objc func cellClicked(gest : MyTapGesture){
        performSegue(withIdentifier: "subCatSeg", sender: self.categoryModels[gest.index])
    }
    
   
}

extension MyWorkoutViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return categoryModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "contentCell", for: indexPath) as? WorkoutTableViewCell {
            
            let category = categoryModels[indexPath.row]
            cell.mView.layer.cornerRadius = 8
           
            cell.mTitle.text = category.title ?? ""
            
            cell.dayLbl.text = dayLabels[indexPath.row % dayLabels.count]
            
            let myGest = MyTapGesture(target: self, action: #selector(cellClicked))
            myGest.index = indexPath.row
            cell.mView.isUserInteractionEnabled = true
            cell.mView.addGestureRecognizer(myGest)
            
            
            
            return cell
        }
        return WorkoutTableViewCell()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        for subview in cell.subviews {
            if String(describing: Swift.type(of: subview)) == "UITableViewCellReorderControl" {
                for case let imageView as UIImageView in subview.subviews {
                    imageView.tintColor = .white// Set your desired color
                    imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate) // Apply the tint
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Allow all rows to be moved
        return true
    }

    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
   
     
            // Update the local data source
            let movedCategory = categoryModels.remove(at: sourceIndexPath.row)
            categoryModels.insert(movedCategory, at: destinationIndexPath.row)
            
            // Save the reordered categories to Firebase
            let orderedIds = categoryModels.map { $0.id } // Get the IDs in the new order
            let userId = Auth.auth().currentUser?.uid ?? "defaultUser" // Replace with actual user identifier
            
        let preferencesRef = Firestore.firestore().collection("Users").document(userId).collection("Preferences").document(catId!)
            preferencesRef.setData(["categoryOrder": orderedIds],merge: true) { error in
                if let error = error {
                    print("Failed to save preferences: \(error)")
                } else {
                    print("Preferences saved successfully")
                }
            }
  

        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        // No delete icon while editing
        return .none
    }
  
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        // Avoid indentation while editing
        return false
    }

    
}

extension MyWorkoutViewController : ReloadSubCatInterface {
    func reloadSubCat(type: String?, catName: String?, catId: String?) {
        self.loadApp(type: type, catName: catName, catId: catId)
    }
    
    
}
