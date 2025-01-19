//
//  SelectWorkouViewController.swift
//  Royal Australian Navy Fitness
//
//  Created by Vijay Rathore on 11/01/24.
//

import UIKit

class RoyalSelectWorkouViewController : UIViewController {
    
    
    @IBOutlet weak var startBtn: UIButton!
    
    @IBOutlet weak var workoutTF: UITextField!
    @IBOutlet weak var gymName: UILabel!
    @IBOutlet weak var backBtn: UIImageView!
    var sGym : String?
    let pickerView = UIPickerView()

    override func viewDidLoad() {
        
        guard let sGym = sGym else {
            
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
            
        }
        gymName.text = sGym
        
        backBtn.isUserInteractionEnabled = true
        backBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnClicked)))
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()

        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.dismissKeyboard))

        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true

        workoutTF.inputAccessoryView = toolBar

        
        startBtn.layer.cornerRadius = 8
        pickerView.delegate = self
        pickerView.dataSource = self
        workoutTF.inputView = pickerView
        
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc func backBtnClicked(){
        self.dismiss(animated: true)
    }
    
    @IBAction func startBtnClicked(_ sender: Any) {
        
        let workoutName = workoutTF.text
        if workoutName == "" {
            self.showToast(message: "Select Workout")
        }
        else {
            performSegue(withIdentifier: "workoutCounterSeg", sender: workoutName)
        }
      
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "workoutCounterSeg" {
            if let VC = segue.destination as? RoyalWorkoutCounterController {
                if let workoutName = sender as? String {
                    VC.sWorkout = workoutName
                }
            }
        }
    }
    
}


extension RoyalSelectWorkouViewController : UIPickerViewDelegate ,UIPickerViewDataSource{
    
    // Number of columns in picker view
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    // Number of rows in picker view
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Constants.WORKOUTS.count // Assuming 'workouts' is your array of strings
    }

    // Title for each row
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Constants.WORKOUTS[row]
    }

    // Handle the selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        workoutTF.text = Constants.WORKOUTS[row]
    }

}
