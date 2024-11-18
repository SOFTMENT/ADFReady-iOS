//
//  PFATestingViewController.swift
//  Adf Ready
//
//  Created by Vijay Rathore on 16/11/24.
//

import UIKit

class PFATestingViewController : UIViewController {
   
    override func viewDidLoad() {
       
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }
    
    @objc func hideKeyboard(){
        self.view.endEditing(true)
    }
}
