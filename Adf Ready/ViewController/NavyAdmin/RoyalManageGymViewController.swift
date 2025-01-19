//
//  ManageGymViewController.swift
//  Royal Australian Navy Fitness
//
//  Created by Vijay Rathore on 11/01/24.
//

import UIKit
import Firebase

class RoyalManageGymViewController : UIViewController {
    @IBOutlet weak var backView: UIImageView!
    @IBOutlet weak var addView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noGymAvailable: UILabel!
    var gymModels = Array<GymModel>()
    override func viewDidLoad() {
        
        tableView.delegate = self
        tableView.dataSource = self
        
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
       
        addView.isUserInteractionEnabled = true
        addView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addViewClicked)))
        
        getAllGym()
    }
    
    func getAllGym(){
        self.ProgressHUDShow(text: "")
        Firestore.firestore().collection("Gyms").order(by: "gymName",descending: false).addSnapshotListener { snapshot, error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error.localizedDescription)
            }
            else {
                self.gymModels.removeAll()
                if let snapshot = snapshot,!snapshot.isEmpty {
                    for qdr in snapshot.documents {
                        if let gymModel = try? qdr.data(as: GymModel.self) {
                            self.gymModels.append(gymModel)
                        }
                    }
                }
                
                self.tableView.reloadData()
                
            }
        }
    }
    
    @objc func addViewClicked(){
            performSegue(withIdentifier: "addGymSeg", sender: nil)
    }
    
    @objc func backViewClicked() {
        self.dismiss(animated: true)
    }
    
    @objc func deleteBtnClicked(value : MyTapGesture){
        let alert = UIAlertController(title: "DELETE", message: "Are you sure you want to delete this gym?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
            self.ProgressHUDShow(text: "Deleting...")
            Firestore.firestore().collection("Gyms").document(value.id).delete { error in
                self.ProgressHUDHide()
                if let error = error {
                    self.showError(error.localizedDescription)
                }
                else {
                    self.showToast(message: "Deleted")
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc func shareQRCode(value : MyTapGesture) {
        if let image = generateQRCode(from: value.id) {
            self.shareImage(image: image)
        }
    }
    func shareImage(image: UIImage) {
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        
        // If you're using a view controller, present it
        self.present(activityViewController, animated: true, completion: nil)
        
        // For iPad, you may need to set the popover presentation controller's source view
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = self.view
            // Set the location of the popover on the screen, perhaps using a button's frame
            popoverController.sourceRect = self.view.bounds
        }
    }
    
    @objc func cellClicked(value : MyTapGesture){
        self.performSegue(withIdentifier: "gymSubcategorySeg", sender: self.gymModels[value.index])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "gymSubcategorySeg" {
            if let VC = segue.destination as? AdminSubCategoryViewController {
                if let category = sender as? GymModel {
                    VC.catId = category.gymName!
                    VC.catName = category.gymName!
                    VC.type = "Gyms"
                }
            }
        }
    }
}


extension RoyalManageGymViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        noGymAvailable.isHidden = gymModels.count > 0 ? true : false
        return gymModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "gymCell", for: indexPath) as? ManageGymTableViewCell {
        
            let gymModel = gymModels[indexPath.row]
            cell.mView.layer.cornerRadius = 8
            cell.mName.text = gymModel.gymName ?? ""
            
            cell.mImage.layer.cornerRadius = 8
            
            if let path = gymModel.gymImage, !path.isEmpty {
                cell.mImage.sd_setImage(with: URL(string: path), placeholderImage: UIImage(named: "placeholder"))
            }
            
            let deleteGest = MyTapGesture(target: self, action: #selector(deleteBtnClicked(value: )))
            deleteGest.id = gymModel.gymName ?? ""
            cell.deleteGym.isUserInteractionEnabled = true
            cell.deleteGym.addGestureRecognizer(deleteGest)
            
            let qrGest = MyTapGesture(target: self, action: #selector(shareQRCode(value: )))
            qrGest.id = gymModel.gymName ?? "123"
            cell.qrCode.isUserInteractionEnabled = true
            cell.qrCode.addGestureRecognizer(qrGest)
            
            cell.mView.isUserInteractionEnabled = true
            let mGest = MyTapGesture(target: self, action: #selector(cellClicked(value: )))
            mGest.index = indexPath.row
            cell.mView.addGestureRecognizer(mGest)
            
            return cell
        }
        return ManageGymTableViewCell()
    }
    
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")

            guard filter.outputImage != nil else {
                return nil
            }
            let scaleX = 300.0
            let scaleY = 300.0
            let transform = CGAffineTransform(scaleX: scaleX, y: scaleY)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        return nil
    }
    
}
