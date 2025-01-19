//
//  CreateSubcategoryViewController.swift
//  Royal Australian Navy
//
//  Created by Vijay Rathore on 27/10/23.
//

import UIKit
import AVKit
import FirebaseStorage
import MobileCoreServices
import AssetsLibrary
import Firebase
import AWSS3
import AWSCore

class RoyalCreateSubcategoryViewController : UIViewController {
    @IBOutlet weak var backView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var topTitle: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var titleTF: UITextField!
  
    @IBOutlet weak var linkCatTitle: UILabel!
    @IBOutlet weak var linkCatView: UIView!
    @IBOutlet weak var uploadVideoBtn: UIButton!
    @IBOutlet weak var uploadPDFBtn: UIButton!
   
    @IBOutlet weak var createBtn: UIButton!
    var isImageChanged = false
    var type : String?
    var catId : String?
    var subId : String?
    var pdfURL : URL?

    var multiVideoModels = Array<MultiVideoModel>()
    var categories = Array<CategoryModel>()
    var selectedCatName : String?
    var selectedCatId : String?
    var accountType : ACCOUNT_TYPE?
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    
    
    override func viewDidLoad() {
        
        
        guard let type = type else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }

        topTitle.text = "Add \(type)"
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))

        linkCatView.isUserInteractionEnabled = true
        linkCatView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(linkCatClicked)))
        
        titleTF.delegate = self
        linkCatView.layer.cornerRadius = 8
    
        image.layer.cornerRadius = 8
        createBtn.layer.cornerRadius = 8
        
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
        
        //TapToChangeImage
        image.isUserInteractionEnabled = true
        image.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeImages)))
    
        uploadPDFBtn.layer.cornerRadius = 8
        uploadVideoBtn.layer.cornerRadius = 8
        
        //TableViewDelegate
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isEditing = true
        
        
        if self.type! == "Gyms" {
            self.linkCatView.isHidden = true
            self.uploadVideoBtn.isHidden = true
            
        }
        else {
            getAllCategory(type: accountType! == .PREJOINER ? "Workouts" : "AdminWorkouts") { categories in
                self.categories.removeAll()
                self.categories.append(contentsOf: categories ?? [])
                
                self.getAllCategory(type: self.accountType! == .PREJOINER ? "Informations" : "AdminInformations") { categories1 in
                    self.categories.append(contentsOf: categories1 ?? [])
                    self.categories.sort { cat1, cat2 in
                        if cat1.title! < cat2.title! {
                            return true
                        }
                        return false
                    }
                }
            }
        }
    
    }
    
    
    
    @objc func changeImages() {
        
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = .photoLibrary
        image.allowsEditing = true
        self.present(image,animated: true)
    }
    
    @IBAction func uploadVideo(_ sender: Any) {
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = .photoLibrary
        image.mediaTypes = ["public.movie"]
        self.present(image,animated: true)
    }
    
    @IBAction func uploadPDF(_ sender: Any) {
        let supportedTypes: [UTType] = [UTType.pdf]
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes)
   
        documentPicker.delegate = self
        
        present(documentPicker, animated: true, completion: nil)
    }
    
    @objc func linkCatClicked(){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        for category in categories {
            alert.addAction(UIAlertAction(title: category.title!, style: .default, handler: { action in
                self.linkCatTitle.text = action.title!
                self.selectedCatName = action.title
                if let catModel = self.categories.first(where: { catModel in
                    if catModel.title == action.title! {
                        return true
                    }
                    return false
                }) {
                    self.selectedCatId = catModel.id
                }

            }))
            
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    
    @IBAction func createBtnClicked(_ sender: Any) {
        let mTitle = titleTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
       
        if !isImageChanged {
            self.showToast(message: "Uplaod Image")
        }
        else if mTitle == "" {
            self.showToast(message: "Enter Title")
        }
        else if self.pdfURL == nil && self.multiVideoModels.count == 0 {
            self.showToast(message: "Upload Video or PDF")
        }
        else {
            let contentModel = ContentModel()
            if type == "Workouts" {
                contentModel.id = Firestore.firestore().collection(type!).document(catId!).collection("Sub").document().documentID
            }
            else {
                var docRef = Firestore.firestore().collection(type!).document(catId!)
                if let subId = self.subId {
                    docRef = docRef.collection("SubWorkouts").document(subId)
                }
                contentModel.id = docRef.collection("Sub").document().documentID
            }
           
            contentModel.date = Date()
            contentModel.title = mTitle
            contentModel.hyperLink = selectedCatName
            contentModel.hyperLinkId = selectedCatId
            contentModel.orderIndex = 0
            let batch = Firestore.firestore().batch()
            var i = 0
            for multiVideoModel in multiVideoModels {
                multiVideoModel.orderIndex = i
                if type == "Workouts" {
                    let docRef = Firestore.firestore().collection(type!).document(catId!).collection("Sub").document(contentModel.id!).collection("Videos").document(multiVideoModel.id!)
                    try! batch.setData(from: multiVideoModel, forDocument: docRef)
                    i = i + 1
                }
                else {
                    
                    var docRef = Firestore.firestore().collection(type!).document(catId!)
                    if let subId = self.subId {
                        docRef = docRef.collection("SubWorkouts").document(subId)
                    }
                
                    docRef = docRef.collection("Sub").document(contentModel.id!).collection("Videos").document(multiVideoModel.id!)
                    try! batch.setData(from: multiVideoModel, forDocument: docRef)
                    i = i + 1
                }
               
            }
            batch.commit { error in
                if let error = error {
                    print("Batch -  \(error.localizedDescription)")
                }
               
            }
            
            contentModel.videoCount = self.multiVideoModels.count
           
            self.ProgressHUDShow(text: "Uploading Image...")
            self.uploadImageOnFirebase(id: contentModel.id!) { imageURL in
                self.ProgressHUDHide()
                if imageURL != "" {
                    contentModel.image = imageURL
                 
       
                    if self.pdfURL != nil {
                        self.ProgressHUDShow(text: "Uploading PDF...")
                        self.uploadPdfOnFirebase(id: contentModel.id!) { pdfURL in
                            self.ProgressHUDHide()
                            if pdfURL != "" {
                                contentModel.pdfLink = pdfURL
                                self.addCotentOnFirebase(contentModel: contentModel)
                               
                                
                            }
                            else {
                                self.showToast(message: "PDF Upload Failed")
                            }
                            
                            
                           
                        }
                    }
                    else {
                        self.addCotentOnFirebase(contentModel: contentModel)
                    }

                
                }
                else {
                    self.showToast(message: "Image Upload Failed")
                }
            }
            
        }
    }
    func initAspectRatioOfVideo(with fileURL: URL) -> Double {
        let resolution = self.resolutionForLocalVideo(url: fileURL)
        guard let width = resolution?.width, let height = resolution?.height else {
            return 0
        }

        return Double(width / height)
    }
    private func resolutionForLocalVideo(url: URL) -> CGSize? {
        guard let track = AVURLAsset(url: url).tracks(withMediaType: AVMediaType.video).first else {
            return nil
        }
        let size = track.naturalSize.applying(track.preferredTransform)
        return CGSize(width: abs(size.width), height: abs(size.height))
    }
    func addCotentOnFirebase(contentModel : ContentModel){
        ProgressHUDShow(text: "")
        if type == "Workouts" {
            try? Firestore.firestore().collection(type!).document(catId!).collection("Sub").document(contentModel.id!).setData(from: contentModel,completion: { error in
                self.ProgressHUDHide()
                if let error = error {
                    self.showToast(message: error.localizedDescription)
                }
                else {
                    self.showToast(message: "Added")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        self.dismiss(animated: true)
                    }
                }
            })
        }
        else {
            if let subId = subId {
                try? Firestore.firestore().collection(type!).document(catId!).collection("SubWorkouts").document(subId).collection("Sub").document(contentModel.id!).setData(from: contentModel,completion: { error in
                    self.ProgressHUDHide()
                    if let error = error {
                        self.showToast(message: error.localizedDescription)
                    }
                    else {
                        self.showToast(message: "Added")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                            self.dismiss(animated: true)
                        }
                    }
                })
            }
            else {
                try? Firestore.firestore().collection(type!).document(catId!).collection("Sub").document(contentModel.id!).setData(from: contentModel,completion: { error in
                    self.ProgressHUDHide()
                    if let error = error {
                        self.showToast(message: error.localizedDescription)
                    }
                    else {
                        self.showToast(message: "Added")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                            self.dismiss(animated: true)
                        }
                    }
                })
            }
         
        }
      
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    @objc func backViewClicked(){
        self.dismiss(animated: true)
    }
    
    @objc func cellClicked(gest : MyTapGesture){
        
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Play", style: .default, handler: { action in
            let playerViewController = AVPlayerViewController()
            let newPlayer  = AVPlayer(playerItem: AVPlayerItem(url: URL(string:Constants.AWS_ROYAL_URL+"/"+gest.id)!))
            
            playerViewController.player = newPlayer
            
            self.present(playerViewController, animated: true) {
                playerViewController.player!.play()
                
            }
        }))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
            self.ProgressHUDShow(text: "Deleting...")
            self.deleteFileFromS3(bucketName: "royalbucket", s3FileName: gest.id) { error in
                DispatchQueue.main.async {
                    self.ProgressHUDHide()
                    if let error = error {
                        self.showError(error.localizedDescription)
                    }
                    else {
                        self.multiVideoModels.remove(at: gest.index)
                        self.tableView.reloadData()
                    }
                }
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}

extension RoyalCreateSubcategoryViewController :  UITextFieldDelegate, UITextViewDelegate {
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true;
    }
  
    
    
    func uploadPdfOnFirebase(id : String, completion : @escaping (String) -> Void ) {
        
        let storage = Storage.storage().reference().child(type!).child(catId!).child("\(id).pdf")
        var downloadUrl = ""
        
        
        let metadata = StorageMetadata()
        //specify MIME type
        
        metadata.contentType = "application/pdf"
       
        let isAccessing = pdfURL!.startAccessingSecurityScopedResource()
        
        if let videoData = try? Data(contentsOf: pdfURL!) {
            
            storage.putData(videoData, metadata: metadata) { metadata, error in
                if error == nil {
                    storage.downloadURL { (url, error) in
                        if error == nil {
                            downloadUrl = url!.absoluteString
                        }
                        if isAccessing {
                            self.pdfURL!.stopAccessingSecurityScopedResource()
                        }
                        completion(downloadUrl)
                        
                    }
                }
                else {
                    if isAccessing {
                        self.pdfURL!.stopAccessingSecurityScopedResource()
                    }
                    print(error!.localizedDescription)
                    completion(downloadUrl)
                }
            }
        }
        else {
            if isAccessing {
                self.pdfURL!.stopAccessingSecurityScopedResource()
            }
            completion(downloadUrl)
            self.showToast(message: "Error PDF")
        }
        
    }
    
 



  

    func uploadImageOnFirebase( id : String,completion : @escaping (String) -> Void ) {
        
        
        var storage : StorageReference!
        storage = Storage.storage().reference().child(type!).child(catId!).child("\(id).png")
       
        var downloadUrl = ""
        let uploadData = (self.image.image?.jpegData(compressionQuality: 0.4))!
    
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
extension RoyalCreateSubcategoryViewController :  UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
            isImageChanged = true
            image.image = editedImage
        }
        else {
            
            
            if let videoURL = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerMediaURL") ] as? URL {
                let avplayeritem = AVPlayerItem(url: videoURL as URL)
               
                   let totalSeconds = avplayeritem.asset.duration.seconds
                   let hours = Int(totalSeconds / 3600)
                   let minutes = Int((totalSeconds.truncatingRemainder(dividingBy: 3600)) / 60)
                   let seconds = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
                   var duration = ""
                   if hours > 0 {
                      duration =  String(format: "%i:%02i:%02i", hours, minutes, seconds)
                   } else {
                      duration = String(format: "%02i:%02i", minutes, seconds)
                       
                   }
                
               
                let videoID = Firestore.firestore().collection(type!).document(catId!).collection("Videos").document().documentID
                let multiVideoModel = MultiVideoModel()
                multiVideoModel.id = videoID
                multiVideoModel.duration = duration
                multiVideoModel.ratio = initAspectRatioOfVideo(with: videoURL)
                let videoName = videoURL.lastPathComponent.removingPercentEncoding
                multiVideoModel.name = videoName ?? "Video"
                self.ProgressHUDShow(text: "Video Uploading...")
            
                self.uploadVideoToS3(fileUrl: videoURL, bucketName: "royalbucket", s3FileName:"Videos/\(videoID).mp4") { error in
                    DispatchQueue.main.async {
                    self.ProgressHUDHide()
                    if let error = error {
                        self.showError(error.localizedDescription)
                    }
                    else {
                
                        let downloadURL = "Videos/" + videoID+".mp4"
                            multiVideoModel.videoURL = downloadURL
                            self.multiVideoModels.append(multiVideoModel)
                            self.tableView.reloadData()
                          
                        }
                    }
                   
                   
                }
            }
            else {
                self.showError("Something went wrong")
            }

         
         

        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func updateTableViewHeight(){
        tableViewHeight.constant = tableView.contentSize.height
        self.tableView.layoutIfNeeded()
    }
}
extension RoyalCreateSubcategoryViewController : UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        uploadPDFBtn.setTitle("PDF Uploaded", for: .normal)
        uploadPDFBtn.setTitleColor(.white, for: .normal)
        uploadPDFBtn.backgroundColor = UIColor(red: 75/255, green: 181/255, blue: 67/255, alpha: 1)
        
        pdfURL = urls[0]
        
    
    }
}


extension RoyalCreateSubcategoryViewController : UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.isHidden = multiVideoModels.count > 0 ? false : true
   
        return multiVideoModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "multiVideoCell", for: indexPath) as? RoyalMultiVideoTableViewCell {
            
            cell.mView.layer.cornerRadius = 8
            let multiVideo = self.multiVideoModels[indexPath.row]
            
            cell.videoName.text = multiVideo.name ?? ""
            
            cell.mView.isUserInteractionEnabled = true
            let gest = MyTapGesture(target: self, action: #selector(cellClicked(gest: )))
            gest.id = multiVideo.videoURL!
            gest.index = indexPath.row
            cell.mView.addGestureRecognizer(gest)
            
            DispatchQueue.main.async {
                self.updateTableViewHeight()
            }
            
            return cell
        }
        
        
        
        return RoyalMultiVideoTableViewCell()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // 1. Update your data model
            multiVideoModels.remove(at: indexPath.row)
            
            // 2. Update the table view
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // Reorder your data source array based on this
        let movedObject = self.multiVideoModels[sourceIndexPath.row]
        multiVideoModels.remove(at: sourceIndexPath.row)
        multiVideoModels.insert(movedObject, at: destinationIndexPath.row)

       
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
}
