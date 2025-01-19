//
//  InformationsCategoryViewController.swift
//  Royal Australian Navy
//
//  Created by Vijay Rathore on 26/10/23.
//

import UIKit
import FirebaseFirestore

class RoyalInformationsCategoryViewController : UIViewController {
    
    @IBOutlet weak var backView: UIImageView!
    
    @IBOutlet weak var addBtn: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    var categoryModels = Array<CategoryModel>()
    @IBOutlet weak var noCategoriesAvailable: UILabel!
    var accountType : ACCOUNT_TYPE?
    override func viewDidLoad() {
        
        guard let accountType = accountType else {
            
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            
            return
        }
       
        
        addBtn.isUserInteractionEnabled = true
        addBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addBtnClicked)))
        
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isEditing = true
        
       
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
        
        
        self.getAllCategory(type: accountType == .PREJOINER ? "Informations" : "AdminInformations") { categories in
          
            self.categoryModels.removeAll()
            self.categoryModels.append(contentsOf: categories ?? [])
            self.tableView.reloadData()
        }
        
    }
    
    @objc func backViewClicked() {
        self.dismiss(animated: true)
    }
    
    @objc func addBtnClicked(){
        performSegue(withIdentifier: "addInformationCatSeg", sender: nil)
    }
    @objc func cellClicked(gest : MyTapGesture){
      
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Manage Contents", style: .default, handler: { action in
            self.performSegue(withIdentifier: "informationSubcategorySeg", sender: self.categoryModels[gest.index])
        }))
        
        alert.addAction(UIAlertAction(title: "Edit Category", style: .default, handler: { action in
            self.performSegue(withIdentifier: "updateInformationCatSeg", sender: self.categoryModels[gest.index])
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "informationSubcategorySeg" {
            if let VC = segue.destination as? RoyalAdminSubCategoryViewController {
                if let category = sender as? CategoryModel {
                    VC.catId = category.id
                    VC.catName = category.title
                    VC.accountType = self.accountType
                    VC.type = self.accountType! == .PREJOINER ? "Informations" : "AdminInformations"
                }
            }
        }
        else if segue.identifier == "addInformationCatSeg" {
            if let VC = segue.destination as? CreateCategoryViewController {
                VC.type = self.accountType! == .PREJOINER ? "Informations" : "AdminInformations"
              
            }
        }
        else if segue.identifier == "updateInformationCatSeg" {
            if let VC = segue.destination as? RoyalUpdateCategoryViewController {
                if let category = sender as? CategoryModel {
                
                    VC.accountType = self.accountType
                    VC.catModel = category
                    VC.type = self.accountType! == .PREJOINER ? "Informations" : "AdminInformations"
                }
            }
        }
    }
    
   
    
}
extension RoyalInformationsCategoryViewController : UITableViewDelegate, UITableViewDataSource {
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
            let docRef = Firestore.firestore().collection(self.accountType! == .PREJOINER ? "Informations" : "AdminInformations").document(item.id!)
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
