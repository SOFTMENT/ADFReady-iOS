//
//  TrackViewController.swift
//  Adf Ready
//
//  Created by Vijay Rathore on 23/11/24.
//

import UIKit

class TrackViewController : UIViewController {
    @IBOutlet weak var backView: UIImageView!
    
    @IBOutlet weak var searchTF: CustomTextField!
    var allUsers : [UserModel] = []
    var useUsers : [UserModel] = []
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnTapped)))
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        
        searchTF.delegate = self
        searchTF.setLeftIcons(icon: UIImage(systemName: "magnifyingglass")!)
        
        tableView.delegate = self
        tableView.dataSource = self
            
        self.ProgressHUDShow(text: "")
        FirebaseStoreManager.db.collection("Users").order(by: "fullName").getDocuments { snapshot, error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error.localizedDescription)
            }
            else {
                
                if let snapshot = snapshot, !snapshot.isEmpty {
                    for qdr in snapshot.documents {
                        if let user = try? qdr.data(as: UserModel.self) {
                            self.allUsers.append(user)
                            self.useUsers.append(user)
                        }
                       
                    }
                    
                }
                self.tableView.reloadData()
            }
        }
                            
    }
                                      
    @objc func hideKeyboard() {
            self.view.endEditing(true)
        }
    
    @objc func backBtnTapped() {
        self.dismiss(animated: true)
    }
}

extension TrackViewController : UITextFieldDelegate {
 
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let searchText = textField.text?.lowercased(), !searchText.isEmpty else {
            self.useUsers = self.allUsers
            tableView.reloadData()
            return
        }

        self.useUsers = self.allUsers.filter { user in
            let nameMatches = user.fullName?.lowercased().contains(searchText) ?? false
            return nameMatches
        }
        tableView.reloadData()
    }
}

extension TrackViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return useUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "trackCell", for:indexPath) as? TrackTableViewCell {
            let user = useUsers[indexPath.row]
            cell.mName.text = user.fullName ?? ""
            cell.appOpenCountLbl.text = String(user.appOpen ?? 0)
            cell.sessionCountLbl.text = String(user.sessionCompleted ?? 0)
            return cell
        }
        return TrackTableViewCell()
        
    }
}
