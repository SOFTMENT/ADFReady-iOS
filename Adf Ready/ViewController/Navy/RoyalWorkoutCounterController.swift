//
//  WorkoutCounterController.swift
//  Royal Australian Navy Fitness
//
//  Created by Vijay Rathore on 12/01/24.
//

import UIKit

class RoyalWorkoutCounterController : UIViewController {
    @IBOutlet weak var workoutName: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var stopBtn: UIImageView!
    var sWorkout : String?
    
    override func viewDidLoad() {
        guard let sWorkout = sWorkout else {
            
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
            
        }
        stopBtn.isUserInteractionEnabled = true
        stopBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(stopBtnClicked)))
        
        workoutName.text = sWorkout
    }
    
    @objc func stopBtnClicked(){
        self.dismiss(animated: true)
    }
}
