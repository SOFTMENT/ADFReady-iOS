//
//  WorkoutViewController.swift
//  Royal Australian Navy
//
//  Created by Vijay Rathore on 16/10/23.
//

import UIKit

class RoyalWorkoutSubcatViewController : UIViewController {

    @IBOutlet weak var backView: UIImageView!
    @IBOutlet weak var catName: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    var categoryModels = Array<CategoryModel>()
    @IBOutlet weak var noCategoriesAvailable: UILabel!
    var catId : String!
    var catNameString : String!
    override func viewDidLoad() {
        
        tableView.dataSource = self
        tableView.delegate = self
        catName.text = catNameString
      
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
    @objc func backViewClicked(){
        self.dismiss(animated: true)
    }
    
    
    @objc func cellClicked(gest : MyTapGesture){
       
            self.performSegue(withIdentifier: "workoutSubCatSeg", sender: self.categoryModels[gest.index])
        
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "workoutSubCatSeg" {
            if let VC = segue.destination as? RoyalSubcategoryViewController {
                if let category = sender as? CategoryModel {
                    VC.catId = self.catId
                    VC.catName = category.title
                    VC.type = self.checkUserOrNavy() == "user" ? "Workouts" : "AdminWorkouts"
                    VC.subId = category.id
                }
            }
        }
        
    }
    
    
    
}
extension RoyalWorkoutSubcatViewController : UITableViewDelegate, UITableViewDataSource {
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
    
}
