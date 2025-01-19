//
//  NavyMembersAccountController.swift
//  Royal Australian Navy Fitness
//
//  Created by Vijay Rathore on 11/01/24.
//

import UIKit
import Firebase

class RoyalNavyMembersAccountController : UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noPendingMembersAvailable: UILabel!
    @IBOutlet weak var backView: UIImageView!
    var pendingUsers = Array<UserModel>()
    override func viewDidLoad() {
        
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
        
        tableView.delegate = self
        tableView.dataSource = self
        
        getAllPendingMember()
        
    }
    
    func getAllPendingMember(){
        self.ProgressHUDShow(text: "")
        Firestore.firestore().collection("NavyMembers").whereField("activeAccount", isEqualTo: false).addSnapshotListener { snapshot, error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error.localizedDescription)
            }
            else {
                self.pendingUsers.removeAll()
                if let snapshot = snapshot, !snapshot.isEmpty {
                    for qdr in snapshot.documents {
                        if let pendingUser = try? qdr.data(as: UserModel.self) {
                            self.pendingUsers.append(pendingUser)
                        }
                    }
                }
                
                self.tableView.reloadData()
            }
        }
    }
    
    
    @objc func backViewClicked() {
        self.dismiss(animated: true)
    }
    
    @objc func approveBtnClicked(value : MyTapGesture){
        ProgressHUDShow(text: "")
        let pendingUser = pendingUsers[value.index]
        Firestore.firestore().collection("NavyMembers").document(value.id).setData(["activeAccount" : true], merge: true) { error in
            
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error.localizedDescription)
            }
            else {
                self.showToast(message: "Approved")
                
                let body = """
                <!DOCTYPE html>
                <html>
                <head>
                    <title>Account Approval</title>
                    <style>
                        body {
                            font-family: Arial, sans-serif;
                        }
                    </style>
                </head>
                <body>
                    <p>
                        Dear <span id="userFullName">\(pendingUser.fullName ?? "")</span>,
                    </p>
                    <p>
                        We are pleased to inform you that your account for our service has been successfully reviewed and approved. You now have full access to all the features and resources available.
                    </p>
                    <p>
                        Warm regards,<br>
                        Royal Australian Navy Fitness
                    </p>
                </body>
                </html>
                """


                
                self.sendMail(to_name: pendingUser.fullName!, to_email: pendingUser.email!, subject: "Your Navy Member Account Has Been Approved", body: body) { error in
                    print(error)
                }
            }
        }
    }
}

extension RoyalNavyMembersAccountController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        noPendingMembersAvailable.isHidden = pendingUsers.count > 0 ? true : false
        return pendingUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "memberPendingCell", for: indexPath) as? PendingUserTableViewCell {
            
            let pendingUser = pendingUsers[indexPath.row]
            cell.mView.layer.cornerRadius = 8
            cell.mName.text = pendingUser.fullName ?? ""
            cell.mEmail.text = pendingUser.email ?? ""
            cell.approveBtn.layer.cornerRadius = 6
            cell.approveBtn.dropShadow()
            cell.approveBtn.isUserInteractionEnabled = true
            let value  = MyTapGesture(target: self, action: #selector(approveBtnClicked(value: )))
            value.id = pendingUser.uid ?? "123"
            value.index = indexPath.row
            cell.approveBtn.addGestureRecognizer(value)
            
            return cell
        }
        return PendingUserTableViewCell()
    }
    
    
}
