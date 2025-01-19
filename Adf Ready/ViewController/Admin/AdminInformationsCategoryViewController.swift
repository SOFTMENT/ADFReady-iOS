//
//  AdminInformationsCategoryViewController.swift
//  Adf Ready
//
//  Created by Vijay Rathore on 20/11/24.
//

//
//  InformationsCategoryViewController.swift
//  Royal Australian Navy
//
//  Created by Vijay Rathore on 26/10/23.
//

import UIKit
import FirebaseFirestore

class AdminInformationsCategoryViewController : UIViewController {
    
    @IBOutlet weak var backView: UIImageView!
    @IBOutlet weak var mTitle: UILabel!
    
    @IBOutlet weak var addBtn: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    var categoryModels = Array<CategoryModel>()
    @IBOutlet weak var noCategoriesAvailable: UILabel!
    var service : String?
    override func viewDidLoad() {
        
        
        guard let service = service else {
            
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
            
        }
        tableView.showsVerticalScrollIndicator = false
        mTitle.text = "Information - \(service.capitalized)"
        
        addBtn.isUserInteractionEnabled = true
        addBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addBtnClicked)))
        
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isEditing = true
        
       
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
        
        
        self.getAllCategory(type: "\(service)Informations") { categories in
          
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
        alert.addAction(UIAlertAction(title: "Add Information", style: .default, handler: { action in
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
            if let VC = segue.destination as? AdminSubCategoryViewController {
                if let category = sender as? CategoryModel {
                    VC.catId = category.id
                    VC.catName = category.title
                    VC.type = "\(service!)Informations"
                }
            }
        }
        else if segue.identifier == "addInformationCatSeg" {
            if let VC = segue.destination as? CreateCategoryViewController {
                VC.type = "\(service!)Informations"
              
            }
        }
        else if segue.identifier == "updateInformationCatSeg" {
            if let VC = segue.destination as? UpdateCategoryViewController {
                if let category = sender as? CategoryModel {
                
                 
                    VC.catModel = category
                    VC.type =  "\(service!)Informations"
                }
            }
        }
    }
    
   
    
}
extension AdminInformationsCategoryViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        noCategoriesAvailable.isHidden = categoryModels.count > 0 ? true : false
        return categoryModels.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        for subview in cell.subviews {
            if String(describing: type(of: subview)) == "UITableViewCellReorderControl" {
                for case let imageView as UIImageView in subview.subviews {
                    imageView.tintColor = .white
                    imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate) // Apply the tint
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        for subview in cell.subviews {
            if String(describing: type(of: subview)) == "UITableViewCellReorderControl" {
                for case let imageView as UIImageView in subview.subviews {
                    imageView.tintColor = .white
                    imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as? CategoryTableViewCell{
            
            let subCatModel = categoryModels[indexPath.row]
            cell.mView.layer.cornerRadius = 8
           
            cell.mTitle.text = subCatModel.title ?? ""
            cell.mDesc.text = subCatModel.desc ?? ""
            
            let myGest = MyTapGesture(target: self, action: #selector(cellClicked(gest: )))
            myGest.index = indexPath.row
            cell.mView.isUserInteractionEnabled = true
            cell.mView.addGestureRecognizer(myGest)
            
            return cell
        }
        return CategoryTableViewCell()
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
            let docRef = Firestore.firestore().collection(self.service!).document(item.id!)
            docRef.updateData(["orderIndex": index])
        }
        
        // Reload rows to ensure custom drag control colors persist
        DispatchQueue.main.async {
               for cell in tableView.visibleCells {
                   if let indexPath = tableView.indexPath(for: cell) {
                       self.tableView(self.tableView, willDisplay: cell, forRowAt: indexPath)
                   }
               }
           }
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
