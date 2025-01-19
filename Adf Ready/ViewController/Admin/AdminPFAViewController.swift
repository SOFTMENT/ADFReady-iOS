//
//  AdminPFAViewController.swift
//  Adf Ready
//
//  Created by Vijay Rathore on 20/11/24.
//

import UIKit

class AdminPFAViewController: UIViewController {
    @IBOutlet weak var backView: UIImageView!
    
    @IBOutlet weak var beepView: RoundedView!
    @IBOutlet weak var sitView: RoundedView!
    @IBOutlet weak var pushView: RoundedView!
    var type = ""
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
        
        pushView.isUserInteractionEnabled = true
        pushView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pushClicked)))
        
        sitView.isUserInteractionEnabled = true
        sitView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sitClicked)))
        
        beepView.isUserInteractionEnabled = true
        beepView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(beepClicked)))
        
    }
    
    
    @objc func pushClicked(){
        self.getPFA(type: "Push") { content in
            if let content = content {
                self.type = "Push"
                self.performSegue(withIdentifier: "updatePFASeg", sender: content)
            }
            else {
                self.performSegue(withIdentifier: "createPFASeg", sender: "Push")
            }
        }
    }
    
    @objc func sitClicked(){
        self.getPFA(type: "Sit") { content in
            if let content = content {
                self.type = "Sit"
                self.performSegue(withIdentifier: "updatePFASeg", sender: content)
            }
            else {
                self.performSegue(withIdentifier: "createPFASeg", sender: "Sit")
            }
        }

    }
    
    @objc func beepClicked(){
        self.getPFA(type: "Beep") { content in
            if let content = content {
                self.type = "Beep"
                self.performSegue(withIdentifier: "updatePFASeg", sender: content)
            }
            else {
                self.performSegue(withIdentifier: "createPFASeg", sender: "Beep")
            }
        }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      
        if segue.identifier == "updatePFASeg" {
            
            if let VC = segue.destination as? UpdatePFAViewController {
                if let sender = sender as? ContentModel {
                    VC.contentModel = sender
                    VC.type = self.type
                        
                }
            }
        }
        else if segue.identifier == "createPFASeg" {
            if let VC = segue.destination as? CreatePFAViewController {
                if let sender = sender as? String {
                  
                    VC.type = sender
                        
                }
            }
        }

    }
    
    @objc func backViewClicked(){
        self.dismiss(animated: true)
    }
}
