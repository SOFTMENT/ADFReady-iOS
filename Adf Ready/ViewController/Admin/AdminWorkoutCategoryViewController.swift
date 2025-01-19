//
//  AdminWorkoutCategoryViewController.swift
//  Adf Ready
//
//  Created by Vijay Rathore on 20/11/24.
//

//
//  WorkoutCategoryViewController.swift
//  Royal Australian Navy
//
//  Created by Vijay Rathore on 26/10/23.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class AdminWorkoutCategoryViewController : UIViewController {
    
    
    @IBOutlet weak var mTile: UILabel!
    @IBOutlet weak var addBtn: UIImageView!
    @IBOutlet weak var backView: UIImageView!
    
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
        mTile.text = "Workout - \(service.capitalized)"
        
        addBtn.isUserInteractionEnabled = true
        addBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addBtnClicked)))
        
        tableView.showsVerticalScrollIndicator = false
        tableView.dataSource = self
        tableView.delegate = self
    
        tableView.isEditing = true
        
        ProgressHUDShow(text: "")
        self.getAllCategory(type: "\(service)Workouts") { categories in
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
        alert.addAction(UIAlertAction(title: "Add Workouts", style: .default, handler: { action in
            let isItGym = self.categoryModels[gest.index].isItGymCategory ?? false
            if isItGym {
                self.performSegue(withIdentifier: "gymWorkoutSeg", sender: self.categoryModels[gest.index])
            }
            else {
                self.performSegue(withIdentifier: "subSeg" , sender: self.categoryModels[gest.index])
            }
          
        }))
        
        alert.addAction(UIAlertAction(title: "Edit Category", style: .default, handler: { action in
            self.performSegue(withIdentifier: "updateWorkoutCatSeg", sender: self.categoryModels[gest.index])
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
    
       if segue.identifier == "subSeg" {
         
                if let VC = segue.destination as? AdminSubCategoryViewController {
                    if let category = sender as? CategoryModel {
                   
                        VC.catId = category.id
                        VC.catName = category.title
                     
                        VC.type = "\(service!)Workouts"
                    }
                }
            
        }
        else if segue.identifier == "gymWorkoutSeg" {
          
            if let VC = segue.destination as? AdminGymWorkoutViewController {
                     if let category = sender as? CategoryModel {
                    
                         VC.catId = category.id
                         VC.cName = category.title
                      
                         VC.type = "\(service!)Workouts"
                     }
                 }
             
         }
        else if segue.identifier == "addWorkoutCatSeg" {
            if let VC = segue.destination as? CreateCategoryViewController {
             
                VC.type = "\(service!)Workouts"
            }
        }
        else if segue.identifier == "updateWorkoutCatSeg" {
            if let VC = segue.destination as? UpdateCategoryViewController {
                if let category = sender as? CategoryModel {
                
              
                    VC.catModel = category
                    
                    VC.type = "\(service!)Workouts"
                }
            }
        }
    }

    
}

extension AdminWorkoutCategoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        noCategoriesAvailable.isHidden = !categoryModels.isEmpty
        return categoryModels.count
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

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as? CategoryTableViewCell else {
            return UITableViewCell()
        }

        let subCatModel = categoryModels[indexPath.row]
        cell.mView.layer.cornerRadius = 8
        cell.mTitle.text = subCatModel.title ?? ""
        cell.mDesc.text = subCatModel.desc ?? ""

        let myGest = MyTapGesture(target: self, action: #selector(cellClicked))
        myGest.index = indexPath.row
        cell.mView.isUserInteractionEnabled = true
        cell.mView.addGestureRecognizer(myGest)

        cell.selectionStyle = .none // Ensure the cell's selection doesn't block views
        cell.backgroundColor = .clear // Ensure the background isn't obscuring the drag handle
        
        return cell
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Allow all rows to be moved
        return true
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // Reorder data source
        let movedObject = categoryModels[sourceIndexPath.row]
        categoryModels.remove(at: sourceIndexPath.row)
        categoryModels.insert(movedObject, at: destinationIndexPath.row)

        // Save new order to Firestore
        for (index, item) in categoryModels.enumerated() {
            if let id = item.id {
                Firestore.firestore().collection(service!).document(id).updateData(["orderIndex": index])
            }
        }
        
        DispatchQueue.main.async {
               for cell in tableView.visibleCells {
                   if let indexPath = tableView.indexPath(for: cell) {
                       self.tableView(self.tableView, willDisplay: cell, forRowAt: indexPath)
                   }
               }
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
