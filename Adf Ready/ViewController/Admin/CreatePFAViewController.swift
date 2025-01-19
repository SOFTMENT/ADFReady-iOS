//
//  CreatePFAViewController.swift
//  Adf Ready
//
//  Created by Vijay Rathore on 21/11/24.
//


import UIKit
import AVKit
import FirebaseStorage
import MobileCoreServices
import AssetsLibrary
import Firebase
import AWSS3
import AWSCore

class CreatePFAViewController : UIViewController {
    @IBOutlet weak var backView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var topTitle: UILabel!
   
    @IBOutlet weak var titleTF: UITextField!
  

    @IBOutlet weak var uploadVideoBtn: UIButton!
    @IBOutlet weak var uploadPDFBtn: UIButton!
   
    @IBOutlet weak var createBtn: UIButton!
   
    var type : String?
    
    
    
    var pdfURL : URL?
    var multiVideoModels = Array<MultiVideoModel>()
 
    var selectedCatName : String?
    var selectedCatId : String?
 
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    
    
    override func viewDidLoad() {
        
        
        guard let type = type else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }
        tableView.showsVerticalScrollIndicator = false
        topTitle.text = "Add \(type)"
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))

     
        
        titleTF.delegate = self
       
    
        
        createBtn.layer.cornerRadius = 8
        
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
        
       
    
        uploadPDFBtn.layer.cornerRadius = 8
        uploadVideoBtn.layer.cornerRadius = 8
        
        //TableViewDelegate
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isEditing = true
        
        
     
         
       
    
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
        else if self.pdfURL == nil && self.multiVideoModels.count == 0 {
            self.showToast(message: "Upload Video or PDF")
        }
        else {
            let contentModel = ContentModel()
         
            
            contentModel.id = self.type!
            contentModel.date = Date()
            contentModel.title = mTitle
            contentModel.orderIndex = 0
            let batch = Firestore.firestore().batch()
            var i = 0
            for multiVideoModel in multiVideoModels {
                multiVideoModel.orderIndex = i
               
                let docRef = Firestore.firestore().collection("PFA").document(type!).collection("Videos").document(contentModel.id!)
                    try! batch.setData(from: multiVideoModel, forDocument: docRef)
                    i = i + 1
               
               
            }
            batch.commit { error in
                if let error = error {
                    print("Batch -  \(error.localizedDescription)")
                }
               
            }
            
            contentModel.videoCount = self.multiVideoModels.count
           
          
                 
       
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
     
            try? Firestore.firestore().collection("PFA").document(type!).setData(from: contentModel,completion: { error in
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
            let newPlayer  = AVPlayer(playerItem: AVPlayerItem(url: URL(string:Constants.AWS_BASE_URL+"/"+gest.id)!))
            
            playerViewController.player = newPlayer
            
            self.present(playerViewController, animated: true) {
                playerViewController.player!.play()
                
            }
        }))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
            self.ProgressHUDShow(text: "Deleting...")
            self.deleteFileFromS3(bucketName: "adfreadybucket", s3FileName: gest.id) { error in
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

extension CreatePFAViewController :  UITextFieldDelegate, UITextViewDelegate {
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true;
    }
  
    
    
    func uploadPdfOnFirebase(id : String, completion : @escaping (String) -> Void ) {
        
        let storage = Storage.storage().reference().child(type!).child("\(id).pdf")
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
    
 



  


}
extension CreatePFAViewController :  UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    
    
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
                
               
                let videoID = Firestore.firestore().collection(type!).document().documentID
                let multiVideoModel = MultiVideoModel()
                multiVideoModel.id = videoID
                multiVideoModel.duration = duration
                multiVideoModel.ratio = initAspectRatioOfVideo(with: videoURL)
                let videoName = videoURL.lastPathComponent.removingPercentEncoding
                multiVideoModel.name = videoName ?? "Video"
                self.ProgressHUDShow(text: "Video Uploading...")
            
                self.uploadVideoToS3(fileUrl: videoURL, bucketName: "adfreadybucket", s3FileName:"Videos/\(videoID).mp4") { error in
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

         
         

      
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func updateTableViewHeight(){
        tableViewHeight.constant = tableView.contentSize.height
        self.tableView.layoutIfNeeded()
    }
}
extension CreatePFAViewController : UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        uploadPDFBtn.setTitle("PDF Uploaded", for: .normal)
        uploadPDFBtn.setTitleColor(.white, for: .normal)
        uploadPDFBtn.backgroundColor = UIColor(red: 75/255, green: 181/255, blue: 67/255, alpha: 1)
        
        pdfURL = urls[0]
        
    
    }
}


extension CreatePFAViewController : UITableViewDelegate, UITableViewDataSource {
    
    
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
            gest.id = multiVideo.videoURL!
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
