//
//  CreateGymViewController.swift
//  Royal Australian Navy Fitness
//
//  Created by Vijay Rathore on 25/01/24.
//

import UIKit
import FirebaseStorage
import GeoFire
import Firebase

class RoyalCreateGymViewController : UIViewController {
    
    
    @IBOutlet weak var backView: UIImageView!
    
    @IBOutlet weak var mImage: UIImageView!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var locationTF: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addBtn: UIButton!
    var places : [Place] = []
    var latitude : Double = 0.0
    var longitude : Double = 0.0
    var isLocationSelected : Bool = false
    var isImageChanged = false
    override func viewDidLoad() {
        
        mImage.layer.cornerRadius = 8
        
        addBtn.layer.cornerRadius = 8
        
        tableView.delegate = self
        tableView.dataSource = self
        
        nameTF.delegate = self
        locationTF.delegate = self
        locationTF.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        
        mImage.isUserInteractionEnabled = true
        mImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeImages)))
        
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnClicked)))
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        
    }
    
    @objc func textFieldDidChange(textField : UITextField){
        guard let query = textField.text, !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            self.places.removeAll()
        
            DispatchQueue.main.async {
            
                self.tableView.reloadData()
            }
           
            return
        }
        
        
     PlacesManager.shared.findPlaces(query: query ) { result in
            switch result {
            case .success(let places) :
                self.places = places
                
                DispatchQueue.main.async {
                    
                    self.tableView.reloadData()
                }
               
                break
            case .failure(let error) :
                print(error)
            }
        }
    }
    
    @objc func locationCellClicked(myGesture : MyTapGesture){
        tableView.isHidden = true
        view.endEditing(true)
    
        let place = places[myGesture.index]
        locationTF.text = place.name ?? ""
        self.latitude = place.coordinates!.latitude
        self.longitude = place.coordinates!.longitude
        self.isLocationSelected = true
     
        
    }

    
    @objc func changeImages() {
        
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = .photoLibrary
        image.allowsEditing = true
        self.present(image,animated: true)
    }
    @objc func hideKeyboard(){
        self.view.endEditing(true)
    }
    
    @objc func backBtnClicked(){
        self.dismiss(animated: true)
    }
    
    @IBAction func addBtnClicked(_ sender: Any) {
        
        let sGym = nameTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let sLocation = locationTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !isImageChanged {
            self.showToast(message: "Upload Gym Image")
        }
        else if sGym == "" {
            self.showToast(message: "Enter Gym Name")
        }
        else if sLocation == "" {
            self.showToast(message: "Enter Location")
        }
        else {
            let gymModel = GymModel()
        
            gymModel.gymName = sGym
            gymModel.gymLatitude = self.latitude
            gymModel.gymLocation = sLocation
            gymModel.gymLongitude = self.longitude
            
            
            let location  = CLLocationCoordinate2D(latitude: self.latitude , longitude: self.longitude)
            let hash = GFUtils.geoHash(forLocation: location)
            gymModel.geoHash = hash
            
            self.ProgressHUDShow(text: "")
            self.uploadImageOnFirebase(id: sGym!) { download in
                gymModel.gymImage = download
                try? Firestore.firestore().collection("Gyms").document(sGym!).setData(from: gymModel) { error in
                    self.ProgressHUDHide()
                    if let error  = error {
                        self.showError(error.localizedDescription)
                    }
                    else {
                        self.showToast(message: "Gym Added")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                            self.dismiss(animated: true)
                        }
                    }
                }
                
                
            }
        }
        
    }
    
    func uploadImageOnFirebase( id : String,completion : @escaping (String) -> Void ) {
        
        
        var storage : StorageReference!
        
        
        storage = Storage.storage().reference().child("GymImages").child(id).child("\(id).png")
        
        
        
        var downloadUrl = ""
        let uploadData = (self.mImage.image?.jpegData(compressionQuality: 0.4))!
        
        storage.putData(uploadData, metadata: nil) { (metadata, error) in
            
            if error == nil {
                storage.downloadURL { (url, error) in
                    if error == nil {
                        downloadUrl = url!.absoluteString
                    }
                    completion(downloadUrl)
                    
                    
                    
                }
            }
            else {
                completion(downloadUrl)
            }
            
        }
    }
}

extension RoyalCreateGymViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
}

extension RoyalCreateGymViewController : UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
            isImageChanged = true
            mImage.image = editedImage
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension RoyalCreateGymViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if places.count > 0 {
            tableView.isHidden = false
        }
        else {
            tableView.isHidden = true
        }

        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "placescell", for: indexPath) as? Google_Places_Cell {
            
            if places.count > indexPath.row {
                cell.name.text = places[indexPath.row].name ?? "Something Went Wrong"
                cell.mView.isUserInteractionEnabled = true
                
                let myGesture = MyTapGesture(target: self, action: #selector(locationCellClicked(myGesture:)))
                myGesture.index = indexPath.row
                cell.mView.addGestureRecognizer(myGesture)
                
            
                return cell
            }
            
           
        }
        
        return Google_Places_Cell()
    }
    
    
    
}
