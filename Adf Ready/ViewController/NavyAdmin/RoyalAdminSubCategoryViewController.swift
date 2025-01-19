//
//  WorkoutSubCategoryViewController.swift
//  Royal Australian Navy
//
//  Created by Vijay Rathore on 27/10/23.
//

import UIKit
import FirebaseFirestore

class RoyalAdminSubCategoryViewController : UIViewController {
    
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
    var accountType : ACCOUNT_TYPE?
    override func viewDidLoad() {
        
        guard let type = type,
        let catName = catName,
              let catId = catId else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }
        
        catLbl.text = catName
        
        addBtn.isUserInteractionEnabled = true
        addBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addBtnClicked)))
        
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnClicked)))
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isEditing = true
        ProgressHUDShow(text: "")
        self.getAllRoyalSubCategory(type: type, catId: catId, subId: self.subId) { contentModels in
            self.ProgressHUDHide()
            self.contentModels.removeAll()
            self.contentModels.append(contentsOf: contentModels ?? [])
            self.tableView.reloadData()
        }
    }
    
    @objc func addBtnClicked(){
        performSegue(withIdentifier: "addSubcategorySeg", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addSubcategorySeg" {
            if let VC = segue.destination as? RoyalCreateSubcategoryViewController {
                VC.type = self.type
                VC.catId = self.catId
                VC.subId = self.subId
                VC.accountType = self.accountType
            }
        }
        else if segue.identifier == "editContentSeg" {
            if let VC = segue.destination as? RoyalUpdateSubcategoryViewController {
                if let contentModel = sender as? ContentModel {
                    VC.type = self.type
                    
                    VC.catId = self.catId
                    VC.contentModel = contentModel
                    VC.accountType = self.accountType
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

extension RoyalAdminSubCategoryViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        noSubcategoryAvailable.isHidden = contentModels.count > 0 ? true : false
        return contentModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "contentCell", for: indexPath) as? RoyalContentTableViewCell{
            
            let contentModel = contentModels[indexPath.row]
            cell.mView.layer.cornerRadius = 8
            cell.mImage.layer.cornerRadius = 6
            if let path = contentModel.image, !path.isEmpty {
                cell.mImage.sd_setImage(with: URL(string: path), placeholderImage: UIImage(named: "placeholder"))
            }
            cell.mTitle.text = contentModel.title ?? ""
           
            cell.pdfImage.isHidden = true
            cell.videoStack.isHidden = true
            
            if contentModel.pdfLink != nil {
                cell.pdfImage.isHidden = false
            }
            
            if let count = contentModel.videoCount, count > 0 {
                
                cell.videoStack.isHidden = false
                cell.duration.text = count > 1 ? "\(count) videos" : "\(count) video"
            }
            
            
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
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
