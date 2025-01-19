//
//  AdminSubCategoryViewController.swift
//  Adf Ready
//
//  Created by Vijay Rathore on 20/11/24.
//

//
//  WorkoutSubCategoryViewController.swift
//  Royal Australian Navy
//
//  Created by Vijay Rathore on 27/10/23.
//

import UIKit
import FirebaseFirestore

class AdminSubCategoryViewController : UIViewController {
    
    var type : String?
    var catName : String?
    var catId : String?
    var subId : String?
    @IBOutlet weak var backView: UIImageView!
    @IBOutlet weak var addBtn: UIImageView!
    @IBOutlet weak var catLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noSubcategoryAvailable: UILabel!
    var contentModels = Array<ContentModel>()
   
    override func viewDidLoad() {
        
        
      
        
        guard let type = type,
        let catName = catName,
              let catId = catId else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }
        tableView.showsVerticalScrollIndicator = false
        catLbl.text = catName
        
        addBtn.isUserInteractionEnabled = true
        addBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addBtnClicked)))
        
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnClicked)))
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isEditing = true
        ProgressHUDShow(text: "")
        
        if let subId = subId, !subId.isEmpty {
            self.getAllRoyalSubCategory(type: type, catId: catId, subId: subId) { contents in
                self.ProgressHUDHide()
                self.contentModels.removeAll()
                self.contentModels.append(contentsOf: contents ?? [])
                self.tableView.reloadData()
            }
        }
        else {
            self.getAllSubCategory(type: type, catId: catId) { contentModels in
                self.ProgressHUDHide()
                self.contentModels.removeAll()
                self.contentModels.append(contentsOf: contentModels ?? [])
                self.tableView.reloadData()
            }
        }
        
    }
    
    @objc func addBtnClicked(){
        performSegue(withIdentifier: "addSubcategorySeg", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "addSubcategorySeg" {
            if let VC = segue.destination as? CreateSubcategoryViewController {
                VC.type = self.type
                VC.catId = self.catId
                VC.subId = self.subId
              
            }
        }
        else if segue.identifier == "editContentSeg" {
            if let VC = segue.destination as? UpdateSubcategoryViewController {
                if let contentModel = sender as? ContentModel {
                    VC.type = self.type
                    
                    VC.catId = self.catId
                    VC.contentModel = contentModel
                 
                    VC.subId = self.subId
                }

            }
        }
    }
    
    @objc func backBtnClicked(){
        self.dismiss(animated: true)
    }
    
    @objc func cellClicked(gest : MyTapGesture){
        performSegue(withIdentifier: "editContentSeg", sender: contentModels[gest.index])
    }
}

extension AdminSubCategoryViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        noSubcategoryAvailable.isHidden = contentModels.count > 0 ? true : false
        return contentModels.count
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        for subview in cell.subviews {
            if String(describing: Swift.type(of: subview)) == "UITableViewCellReorderControl" {
                for case let imageView as UIImageView in subview.subviews {
                    imageView.tintColor = .white
                    imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate) // Apply the tint
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        for subview in cell.subviews {
            if String(describing: Swift.type(of: subview)) == "UITableViewCellReorderControl" {
                for case let imageView as UIImageView in subview.subviews {
                    imageView.tintColor = .white
                    imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "contentCell", for: indexPath) as? ContentTableViewCell{
            
            let contentModel = contentModels[indexPath.row]
            cell.mView.layer.cornerRadius = 8
          
            cell.mTitle.text = contentModel.title ?? ""
           
         
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
        let movedObject = self.contentModels[sourceIndexPath.row]
        contentModels.remove(at: sourceIndexPath.row)
        contentModels.insert(movedObject, at: destinationIndexPath.row)

        // Save the new order to Firestore
        for (index, item) in contentModels.enumerated() {
            // Assuming each item has an ID to identify it in Firestore
            var docRef = Firestore.firestore().collection(type!).document(catId!)
            if let subId = self.subId {
                docRef = docRef.collection("SubWorkouts").document(subId)
            }
            docRef.collection("Sub").document(item.id!).updateData(["orderIndex": index])
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
