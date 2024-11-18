//
//  ViewController.swift
//  Adf Ready
//
//  Created by Vijay Rathore on 15/11/24.
//

import UIKit

class WelcomeViewController : UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
       
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2 ) {
            self.performSegue(withIdentifier: "welcome2Seg", sender: nil)
        }
    }


}

