//
//  UpdateSubcategoryViewController.swift
//  Adf Ready
//
//  Created by Vijay Rathore on 20/11/24.
//

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

class UpdateSubcategoryViewController : UIViewController {
    @IBOutlet weak var backView: UIImageView!
    @IBOutlet weak var deleteBtn: UIImageView!
    
    @IBOutlet weak var topTitle: UILabel!
  
    @IBOutlet weak var titleTF: UITextField!
  
    @IBOutlet weak var uploadVideoBtn: UIButton!
    @IBOutlet weak var uploadPDFBtn: UIButton!

    @IBOutlet weak var createBtn: UIButton!
    var isImageChanged = false
    var type : String?
    var catId : String?
    var subId : String?
    var contentModel : ContentModel?
    var pdfURL : URL?
  
    var selectedCatName : String?
    var selectedCatId : String?
    var multiVideoModels = Array<MultiVideoModel>()
   
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        
        guard let type = type, let contentModel = contentModel else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }
        
        tableView.showsVerticalScrollIndicator = false
        
        topTitle.text = "Update \(type)"
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        
        
        
       
        
        titleTF.delegate = self
        titleTF.text = contentModel.title ?? ""
        
       
        //TableViewDelegate
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isEditing = true
        
        self.ProgressHUDShow(text: "")
        if let subId = subId, !subId.isEmpty {
            getAllVideosGymWorkout(type: type, catId: catId!, sId: subId, subCatId: contentModel.id!) { contents in
              
                self.ProgressHUDHide()
                self.multiVideoModels.removeAll()
                self.multiVideoModels.append(contentsOf: contents ?? [])
                self.tableView.reloadData()
                
            }
            
        }
        else {
            getAllVideos(type: type, catId: catId!, subCatId: contentModel.id!) { contents in
              
                self.ProgressHUDHide()
                self.multiVideoModels.removeAll()
                self.multiVideoModels.append(contentsOf: contents ?? [])
                self.tableView.reloadData()
                
            }
            
        }
        if contentModel.pdfLink != nil {
            uploadPDFBtn.setTitle("PDF Uploaded", for: .normal)
            uploadPDFBtn.setTitleColor(.white, for: .normal)
            uploadPDFBtn.backgroundColor = UIColor(red: 75/255, green: 181/255, blue: 67/255, alpha: 1)
        }
        
        
    
        createBtn.layer.cornerRadius = 8
        
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
        
        
        uploadPDFBtn.layer.cornerRadius = 8
        uploadVideoBtn.layer.cornerRadius = 8
        
        deleteBtn.isUserInteractionEnabled = true
        deleteBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(deleteContentClicked)))
        
      
       
        
        
    }
    
    func updateTableViewHeight(){
        tableViewHeight.constant = tableView.contentSize.height
        self.tableView.layoutIfNeeded()
    }
    

    
    
    @objc func deleteContentClicked(){
        let alert = UIAlertController(title: "Delete", message: "Are you sure you want to delete this item?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
            self.ProgressHUDShow(text: "Deleting...")
            
            let imageStorage = Storage.storage().reference().child(self.type!).child(self.catId!).child("\(self.contentModel!.id!).png")
            imageStorage.delete { error in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
            
            let batch = Firestore.firestore().batch()
            for multiVideoModel in self.multiVideoModels {
               
                
                self.deleteFileFromS3(bucketName: "adfreadybucket", s3FileName: multiVideoModel.videoURL!) { error in
                   
                }
                
                var  docRef = Firestore.firestore().collection(self.type!).document(self.catId!)
                
                if let subId = self.subId {
                    docRef = docRef.collection("SubWorkouts").document(subId)
                }
              
                 docRef = docRef.collection("Sub").document(self.contentModel!.id!).collection("Videos").document(multiVideoModel.id!)
                batch.deleteDocument(docRef)
               
                
            }
            batch.commit { error in
                if let error = error {
                    print("Batch -  \(error.localizedDescription)")
                }
               
            }
            var  docRef1 = Firestore.firestore().collection(self.type!).document(self.catId!)
            
            if let subId = self.subId {
                docRef1 = docRef1.collection("SubWorkouts").document(subId)
            }
          
            docRef1.collection("Sub").document(self.contentModel!.id ?? "123").delete { error in
                self.ProgressHUDHide()
                if let error = error {
                    self.showError(error.localizedDescription)
                }
                else {
                    self.showToast(message: "Deleted")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        self.dismiss(animated: true)
                    }
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
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
    
    
    @IBAction func createBtnClicked(_ sender: Any) {
        let mTitle = titleTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
       
       
        if mTitle == "" {
            self.showToast(message: "Enter Title")
        }
        else {

            self.contentModel!.title = mTitle
            self.contentModel!.hyperLink = selectedCatName
            self.contentModel!.hyperLinkId = selectedCatId
            var i = 0
            let batch = Firestore.firestore().batch()
            for multiVideoModel in multiVideoModels {
                multiVideoModel.orderIndex = i
                
                var  docRef = Firestore.firestore().collection(self.type!).document(self.catId!)
                
                if let subId = self.subId {
                    docRef = docRef.collection("SubWorkouts").document(subId)
                }
                
                docRef = docRef.collection("Sub").document(contentModel!.id!).collection("Videos").document(multiVideoModel.id!)
                try! batch.setData(from: multiVideoModel, forDocument: docRef,merge: true)
                i = i + 1
            }
            batch.commit { error in
                if let error = error {
                    print("Batch -  \(error.localizedDescription)")
                }
               
            }
            
            self.contentModel!.videoCount = self.multiVideoModels.count
            
         
            continueAfterImageUpload()
            
            
        }
    }
    
    func continueAfterImageUpload(){
        
        if self.pdfURL != nil {
            self.ProgressHUDShow(text: "Uploading PDF...")
            self.uploadPdfOnFirebase(id: self.contentModel!.id!) { pdfURL in
                self.ProgressHUDHide()
                if pdfURL != "" {
                    self.contentModel!.pdfLink = pdfURL
                    self.addCotentOnFirebase(contentModel: self.contentModel!)
                    
                }
                else {
                    self.showToast(message: "PDF Upload Failed")
                }
            
            }
        }
        else {
            self.addCotentOnFirebase(contentModel: self.contentModel!)
        }
    }
    
    func addCotentOnFirebase(contentModel : ContentModel){
        ProgressHUDShow(text: "")
       
            if let subId = subId {
                try? Firestore.firestore().collection(type!).document(catId!).collection("SubWorkouts").document(subId).collection("Sub").document(contentModel.id!).setData(from: contentModel,completion: { error in
                    self.ProgressHUDHide()
                    if let error = error {
                        self.showToast(message: error.localizedDescription)
                    }
                    else {
                        self.showToast(message: "Updated")
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
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    @objc func backViewClicked(){
        self.dismiss(animated: true)
    }
    
}

extension UpdateSubcategoryViewController :  UITextFieldDelegate, UITextViewDelegate {
    
    
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
  
    
    @objc func cellClicked(gest : MyTapGesture){
        
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Play", style: .default, handler: { action in
            let playerViewController = AVPlayerViewController()
            let newPlayer  = AVPlayer(playerItem: AVPlayerItem(url: URL(string:Constants.AWS_BASE_URL+"/"+gest.path)!))
            
            playerViewController.player = newPlayer
            
            self.present(playerViewController, animated: true) {
                playerViewController.player!.play()
                
            }
        }))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
            self.ProgressHUDShow(text: "Deleting...")
            self.deleteFileFromS3(bucketName: "adfreadybucket", s3FileName: gest.path) { error in
                DispatchQueue.main.async {
                    self.ProgressHUDHide()
                    if let error = error {
                        self.showError(error.localizedDescription)
                    }
                    else {
                        
                        Firestore.firestore().collection(self.type!).document(self.catId!).collection("Sub").document(self.contentModel!.id!).collection("Videos").document(gest.id).delete()
                        
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
extension UpdateSubcategoryViewController :  UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
   
            
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
                self.uploadVideoToS3(fileUrl: videoURL, bucketName: "adfreadybucket", s3FileName:"Videos/\(videoID).mp4") { error in
                    if let error = error {
                        self.showError(error.localizedDescription)
                    }
                    else {
                        DispatchQueue.main.async {
                            self.ProgressHUDHide()
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

         
         

        
        
        self.dismiss(animated: true, completion: nil)
    }
    
}
extension UpdateSubcategoryViewController : UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        uploadPDFBtn.setTitle("PDF Uploaded", for: .normal)
        uploadPDFBtn.setTitleColor(.white, for: .normal)
        uploadPDFBtn.backgroundColor = UIColor(red: 75/255, green: 181/255, blue: 67/255, alpha: 1)
        
        pdfURL = urls[0]
        
    
    }
}

extension UpdateSubcategoryViewController : UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.isHidden = multiVideoModels.count > 0 ? false : true
        return multiVideoModels.count
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        for subview in cell.subviews {
            if String(describing: Swift.type(of: subview)) == "UITableViewCellReorderControl" {
                for case let imageView as UIImageView in subview.subviews {
                    imageView.tintColor = .white
                    imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate) // Apply the tint
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        for subview in cell.subviews {
            if String(describing: Swift.type(of: subview)) == "UITableViewCellReorderControl" {
                for case let imageView as UIImageView in subview.subviews {
                    imageView.tintColor = .white
                    imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
                }
            }
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "multiVideoCell", for: indexPath) as? MultiVideoTableViewCell {
            
            cell.mView.layer.cornerRadius = 8
            let multiVideo = self.multiVideoModels[indexPath.row]
      
            cell.videoName.text = multiVideo.name ?? ""
            
            cell.mView.isUserInteractionEnabled = true
            let gest = MyTapGesture(target: self, action: #selector(cellClicked(gest: )))
            gest.id = multiVideo.id!
            gest.path = multiVideo.videoURL!
            gest.index = indexPath.row
            
            cell.mView.addGestureRecognizer(gest)
            
            DispatchQueue.main.async {
                self.updateTableViewHeight()
            }
            
            return cell
        }
        
        
        
        return MultiVideoTableViewCell()
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

        // Reload rows to ensure custom drag control colors persist
        DispatchQueue.main.async {
               for cell in tableView.visibleCells {
                   if let indexPath = tableView.indexPath(for: cell) {
                       self.tableView(self.tableView, willDisplay: cell, forRowAt: indexPath)
                   }
               }
           }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
