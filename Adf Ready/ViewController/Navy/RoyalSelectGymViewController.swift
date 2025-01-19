//
//  SelectGymViewController.swift
//  Royal Australian Navy Fitness
//
//  Created by Vijay Rathore on 27/01/24.
//

import UIKit
import Firebase
import MapKit

class RoyalSelectGymViewController : UIViewController {
    
    @IBOutlet weak var logoutBtn: UIButton!
    @IBOutlet weak var selectGymBtn: UIButton!
    
    @IBOutlet weak var gymTF: UITextField!
    @IBOutlet weak var mImage: UIImageView!
    @IBOutlet weak var mName: UILabel!
    @IBOutlet weak var mLocation: UILabel!
    @IBOutlet weak var mStack: UIStackView!
    var gymModels = Array<GymModel>()
    let pickerView = UIPickerView()
    var selectedGym : GymModel?
    override func viewDidLoad() {
        
        
        selectGymBtn.layer.cornerRadius = 8
        
        self.logoutBtn.layer.cornerRadius = 8
        
        mImage.layer.cornerRadius = 8
        mImage.isUserInteractionEnabled = false
        mName.isUserInteractionEnabled = false
        mLocation.isUserInteractionEnabled = false
        
        mStack.isUserInteractionEnabled = true
        mStack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(stackClicked)))
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()

        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.dismissKeyboard))

        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true

        gymTF.inputAccessoryView = toolBar
        pickerView.delegate = self
        pickerView.dataSource = self
        gymTF.inputView = pickerView
        getAllGym()
    
    }
    
    @IBAction func logoutClicked(_ sender: Any) {
        self.logout()
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
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
                
                self.pickerView.reloadAllComponents()
                
            }
        }
    }
    
    
    @IBAction func selectGymClicked(_ sender: Any) {
        performSegue(withIdentifier: "gymSubCatSeg", sender: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gymSubCatSeg" {
            if let VC = segue.destination as? RoyalSubcategoryViewController  {
              
                    VC.catId = self.selectedGym!.gymName!
                    VC.catName = self.selectedGym!.gymName!
                    VC.type = "Gyms"
                    
               
            }
        }
    }
    
    @objc func stackClicked(){
        
        showMapOptions(latitude: self.selectedGym!.gymLatitude!, longitude: self.selectedGym!.gymLongitude!)
    }
    
    
    func showMapOptions(latitude: Double, longitude: Double) {
        let alertController = UIAlertController(title: "Open Location", message: "Choose a Maps App", preferredStyle: .actionSheet)

        // Google Maps Option
        let googleMapsAction = UIAlertAction(title: "Google Maps", style: .default) { (action) in
            if UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!) {
                let googleMapsURL = URL(string: "comgooglemaps://?q=\(latitude),\(longitude)")!
                UIApplication.shared.open(googleMapsURL, options: [:], completionHandler: nil)
            } else {
                self.showToast(message: "Google Maps is not installed.")
            }
        }

        // Apple Maps Option
        let appleMapsAction = UIAlertAction(title: "Apple Maps", style: .default) { (action) in
            let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
            let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
            mapItem.name = "Target Location" // Optional
            mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
        }

        // Cancel Option
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        // Add actions to the alert controller
        alertController.addAction(googleMapsAction)
        alertController.addAction(appleMapsAction)
        alertController.addAction(cancelAction)

        // Present the alert controller
        self.present(alertController, animated: true, completion: nil)
    }

    
}
extension RoyalSelectGymViewController : UIPickerViewDelegate ,UIPickerViewDataSource{
    
    // Number of columns in picker view
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    // Number of rows in picker view
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.gymModels.count
    }

    // Title for each row
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.gymModels[row].gymName ?? ""
    }

    // Handle the selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedGym = self.gymModels[row]
        self.mStack.isHidden = false
        self.selectGymBtn.isHidden = false
        self.mLocation.text = selectedGym!.gymLocation ?? ""
        self.mName.text = self.selectedGym!.gymName ?? ""
        
        if let path  = selectedGym!.gymImage, !path.isEmpty {
            mImage.sd_setImage(with: URL(string: path), placeholderImage: UIImage(named: "placeholder"))
        }
        gymTF.text = self.gymModels[row].gymName ?? ""
    }

}
