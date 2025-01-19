//
//  WorkoutViewController.swift
//  Adf Ready
//
//  Created by Vijay Rathore on 16/11/24.
//

import UIKit

class WorkoutViewController : UIViewController {

 
    @IBOutlet weak var tableView: UITableView!
    var categoryModels = Array<CategoryModel>()
    @IBOutlet weak var noCategoriesAvailable: UILabel!
    
    override func viewDidLoad() {
        
        tableView.dataSource = self
        tableView.delegate = self
        
        
        tableView.showsVerticalScrollIndicator = false
            
            ProgressHUDShow(text: "")
        self.getAllCategory(type:"\(UserModel.data!.service!)Workouts") { categories in
                self.ProgressHUDHide()
                self.categoryModels.removeAll()
                self.categoryModels.append(contentsOf: categories ?? [])
                self.tableView.reloadData()
            }
      
        
    
        
    }
    
    
    @objc func cellClicked(gest : MyTapGesture){
        
        let categoryModel = categoryModels[gest.index]
        if let isItGym = categoryModel.isItGymCategory, isItGym {
            self.performSegue(withIdentifier: "myworkoutSeg", sender: self.categoryModels[gest.index])
         
        }
        else {
            self.performSegue(withIdentifier: "subCatSeg", sender: self.categoryModels[gest.index])
        }
        
            
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "myworkoutSeg" {
          
            if let VC = segue.destination as? MyWorkoutViewController {
                    if let category = sender as? CategoryModel {
                        VC.catId = category.id
                        VC.catName = category.title
                        VC.type = "\(UserModel.data!.service!)Workouts"
                    }
                }
            
        }
        else if segue.identifier == "subCatSeg" {
            if let VC = segue.destination as? SubcategoryViewController  {
                if let category = sender as? CategoryModel {
                    VC.catId = category.id
                    VC.catName = category.title
                    VC.type = "\(UserModel.data!.service!)Workouts"
                    
                }
            }
        }
 
    
        
    }
    
    
    
}
extension  WorkoutViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        noCategoriesAvailable.isHidden = categoryModels.count > 0 ? true : false
        return categoryModels.count
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
    
}
