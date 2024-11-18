//
//  Untitled.swift
//  Adf Ready
//
//  Created by Vijay Rathore on 16/11/24.
//

import UIKit
import SDWebImage

class InformationViewController : UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var categoryModels = Array<CategoryModel>()
    @IBOutlet weak var noCategoriesAvailable: UILabel!
    
    override func viewDidLoad() {
        
        tableView.dataSource = self
        tableView.delegate = self
    
        let accountType = checkUserOrNavy()
            var catName = "Informations"
            if accountType == "user" {
                 catName = "Informations"
            }
            else {
                catName = "AdminInformations"
            }
            
            ProgressHUDShow(text: "")
            self.getAllCategory(type: catName) { categories in
                self.ProgressHUDHide()
                self.categoryModels.removeAll()
                self.categoryModels.append(contentsOf: categories ?? [])
                self.tableView.reloadData()
            }
       
        
        
    }
    
    
    
    
    
    @objc func cellClicked(gest : MyTapGesture){
       
            self.performSegue(withIdentifier: "infoSubCatSeg", sender: self.categoryModels[gest.index])
        
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "infoSubCatSeg" {
            if let VC = segue.destination as? SubcategoryViewController  {
                if let category = sender as? CategoryModel {
                    VC.catId = category.id
                    VC.catName = category.title
                    VC.type = checkUserOrNavy() == "user" ? "Informations" : "AdminInformations"
                    
                }
            }
        }
        
    }
    
    
    
}
extension InformationViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        noCategoriesAvailable.isHidden = categoryModels.count > 0 ? true : false
        return categoryModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as? CategoryTableViewCell{
            
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
        return CategoryTableViewCell()
    }
    
}
