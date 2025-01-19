//
//  SubcategoryViewController.swift
//  Royal Australian Navy
//
//  Created by Vijay Rathore on 16/10/23.
//

import UIKit
import SDWebImage
import FirebaseStorage
import Firebase


class RoyalSubcategoryViewController : UIViewController {
    
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
        
        
        
        ProgressHUDShow(text: "")
        self.getAllRoyalSubCategory(type: type, catId: catId, subId: self.subId) { contentModels in
            self.ProgressHUDHide()
            self.contentModels.removeAll()
            self.contentModels.append(contentsOf: contentModels ?? [])
            self.tableView.reloadData()
            
        }
        
    }
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewContentSeg" {
            if let VC = segue.destination as? RoyalViewContentViewController {
                if let index = sender as? Int {
                    VC.contentModels = contentModels
                    VC.position = index
                    VC.type = self.type
                    VC.delegate = self
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

extension RoyalSubcategoryViewController : UITableViewDelegate, UITableViewDataSource {
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
          
           
            
            getAllRoyalVideos(type: type!, catId: catId!, subId: self.subId, subCatId: contentModel.id!) { contents in
                 contentModel.multiVideoModels = Array<MultiVideoModel>()
                 contentModel.multiVideoModels?.append(contentsOf: contents ?? [])
                 
            
                 
                 if let contents = contents {
                    
                     for multiVideo in contents {
                  
                         if let url  = URL(string: Constants.AWS_ROYAL_URL+"/"+multiVideo.videoURL!) {
                             
                
                             
                             if SDImageCache.shared.diskImageData(forKey: url.absoluteString) == nil {
                                 self.downloadMP4File(from: url)
                             }
                         }
                        
                     }
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

extension RoyalSubcategoryViewController : ReloadSubCatInterface {
    func reloadSubCat(type: String?, catName: String?, catId: String?) {
        self.loadApp(type: type, catName: catName, catId: catId)
    }
    
    
}
