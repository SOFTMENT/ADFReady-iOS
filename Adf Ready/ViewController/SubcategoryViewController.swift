//
//  SubcategoryViewController.swift
//  Adf Ready
//
//  Created by Vijay Rathore on 17/11/24.
//

import UIKit
import SDWebImage
import FirebaseStorage
import Firebase


class SubcategoryViewController : UIViewController {
    
    var type : String?
    var catName : String?
    var catId : String?
    var subId : String?
    @IBOutlet weak var backView: UIImageView!
    
    @IBOutlet weak var catLbl: UILabel!
    @IBOutlet weak var noSubcategoryAvailable: UILabel!
    
 
    @IBOutlet weak var tableView: UITableView!
    
    
    var contentModels = Array<ContentModel>()

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
        
        
        ProgressHUDShow(text: "")
        if let subId = subId, !subId.isEmpty {
            self.getAllRoyalSubCategory(type: type, catId: catId, subId: subId, completion: { contentModels in
                self.ProgressHUDHide()
                self.contentModels.removeAll()
                self.contentModels.append(contentsOf: contentModels ?? [])
                self.tableView.reloadData()
            })
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
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewContentSeg" {
            if let VC = segue.destination as? ViewContentViewController {
                if let index = sender as? Int {
                    VC.contentModels = contentModels
                    VC.position = index
                    VC.type = self.type
                   
                }
            }
        }
    }
    
    @objc func backBtnClicked(){
        self.dismiss(animated: true)
    }
    
    @objc func cellClicked(gest : MyTapGesture){
        performSegue(withIdentifier: "viewContentSeg", sender: gest.index)
    }
}

extension SubcategoryViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        noSubcategoryAvailable.isHidden = contentModels.count > 0 ? true : false
        return contentModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "contentCell", for: indexPath) as? ContentTableViewCell{
            
            let contentModel = contentModels[indexPath.row]
            cell.mView.layer.cornerRadius = 8
           
            cell.mTitle.text = contentModel.title ?? ""
           
      
            self.ProgressHUDShow(text: "")
            if let subId = subId, !subId.isEmpty {
                getAllVideosGymWorkout(type: type!, catId: catId!, sId: subId, subCatId: contentModel.id!) { contents in
                  
                    self.ProgressHUDHide()

                     contentModel.multiVideoModels = Array<MultiVideoModel>()
                     contentModel.multiVideoModels?.append(contentsOf: contents ?? [])
                    
                }
                
            }else {
                getAllVideos(type: type!, catId: catId!, subCatId: contentModel.id!) { contents in
                    self.ProgressHUDHide()
                     contentModel.multiVideoModels = Array<MultiVideoModel>()
                     contentModel.multiVideoModels?.append(contentsOf: contents ?? [])
                        
                
                     
                 
                 }
                
            }
            
            
            
            let myGest = MyTapGesture(target: self, action: #selector(cellClicked(gest: )))
            myGest.index = indexPath.row
            cell.mView.isUserInteractionEnabled = true
            cell.mView.addGestureRecognizer(myGest)
            
            return cell
        }
        return CategoryTableViewCell()
    }
    
  
    


    
}

extension SubcategoryViewController : ReloadSubCatInterface {
    func reloadSubCat(type: String?, catName: String?, catId: String?) {
        self.loadApp(type: type, catName: catName, catId: catId)
    }
    
    
}
