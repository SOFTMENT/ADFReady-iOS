//
//  NavyWorkoutSubcategoryViewController.swift
//  Royal Australian Navy Fitness
//
//  Created by Vijay Rathore on 04/04/24.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class RoyalAdminWorkoutSubcategoryViewController : UIViewController {
    
    @IBOutlet weak var topLbl: UILabel!
    
    @IBOutlet weak var addBtn: UIImageView!
    @IBOutlet weak var backView: UIImageView!
    
    @IBOutlet weak var tableView: UITableView!
    var categoryModels = Array<CategoryModel>()
    @IBOutlet weak var noCategoriesAvailable: UILabel!
    var accountType : ACCOUNT_TYPE?
    var topTitle : String?
    var catId : String!
    var type : String!
    
    
    override func viewDidLoad() {
        
        guard let topTitle = topTitle else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }
        
       
       
        topLbl.text = topTitle
        
        addBtn.isUserInteractionEnabled = true
        addBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addBtnClicked)))
        
        
        tableView.dataSource = self
        tableView.delegate = self
    
        tableView.isEditing = true
        
        ProgressHUDShow(text: "")
        self.getAllSubcategory(catId: catId) { categories in
            self.ProgressHUDHide()
            self.categoryModels.removeAll()
            self.categoryModels.append(contentsOf: categories ?? [])
            self.tableView.reloadData()
        }
        
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
       
    }
    @objc func backViewClicked() {
        self.dismiss(animated: true)
    }
    
    @objc func addBtnClicked(){
        performSegue(withIdentifier: "addWorkoutCatSeg", sender: nil)
    }
    
    
    
    @objc func cellClicked(gest : MyTapGesture){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Manage Contents", style: .default, handler: { action in
            self.performSegue(withIdentifier: "workoutSubcategorySeg", sender: self.categoryModels[gest.index])
        }))
        
        alert.addAction(UIAlertAction(title: "Edit Category", style: .default, handler: { action in
            self.performSegue(withIdentifier: "updateWorkoutCatSeg", sender: self.categoryModels[gest.index])
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "workoutSubcategorySeg" {
            if let VC = segue.destination as? RoyalAdminSubCategoryViewController {
                if let category = sender as? CategoryModel {
                    VC.catId = self.catId
                    VC.subId = category.id
                    VC.catName = category.title
                    VC.accountType = self.accountType
                    VC.type = self.accountType! == .PREJOINER ? "Workouts" : "AdminWorkouts"
                }
            }
        }
        else if segue.identifier == "addWorkoutCatSeg" {
            if let VC = segue.destination as? RoyalCreateCategoryViewController {
                VC.accountType = self.accountType
                VC.catId = catId
                VC.type = self.accountType! == .PREJOINER ? "Workouts" : "AdminWorkouts"
            }
        }
        else if segue.identifier == "updateWorkoutCatSeg" {
            if let VC = segue.destination as? RoyalUpdateCategoryViewController {
                if let category = sender as? CategoryModel {
                
                    VC.accountType = self.accountType
                    VC.catModel = category
                    VC.catId = self.catId
                    VC.type = self.accountType! == .PREJOINER ? "Workouts" : "AdminWorkouts"
                }
            }
        }
    }
}


extension RoyalAdminWorkoutSubcategoryViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        noCategoriesAvailable.isHidden = categoryModels.count > 0 ? true : false
        return categoryModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as? RoyalCategoryTableViewCell{
            
            let subCatModel = categoryModels[indexPath.row]
            cell.mView.layer.cornerRadius = 8
            cell.mImage.layer.cornerRadius = 6
            if let path = subCatModel.image, !path.isEmpty {
                cell.mImage.sd_setImage(with: URL(string: path), placeholderImage: UIImage(named: "placeholder"))
            }
            cell.mTitle.text = subCatModel.title ?? ""
            cell.mDesc.text = subCatModel.desc ?? ""
            
            let myGest = MyTapGesture(target: self, action: #selector(cellClicked(gest: )))
            myGest.index = indexPath.row
            cell.mView.isUserInteractionEnabled = true
            cell.mView.addGestureRecognizer(myGest)
            
            return cell
        }
        return RoyalCategoryTableViewCell()
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // Reorder your data source array based on this
        let movedObject = self.categoryModels[sourceIndexPath.row]
        categoryModels.remove(at: sourceIndexPath.row)
        categoryModels.insert(movedObject, at: destinationIndexPath.row)

        // Save the new order to Firestore
        for (index, item) in categoryModels.enumerated() {
            // Assuming each item has an ID to identify it in Firestore
            let docRef = Firestore.firestore().collection(self.accountType! == .PREJOINER ? "Workouts" : "AdminWorkouts").document(self.catId).collection("SubWorkouts").document(item.id!)
            docRef.updateData(["orderIndex": index])
        }
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
