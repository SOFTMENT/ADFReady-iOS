//
//  ViewContentViewController.swift
//  Royal Australian Navy
//
//  Created by Vijay Rathore on 30/10/23.
//

import UIKit
import WebKit
import AVFoundation
import Firebase
import AVKit
import SDWebImage

class RoyalViewContentViewController : UIViewController, WKUIDelegate,WKNavigationDelegate  {
  
    @IBOutlet weak var videoRatio: NSLayoutConstraint!
    
    @IBOutlet weak var mainCompletedBtn: UIView!
    @IBOutlet weak var hyperLinkView: UIView!
    var contentModels : Array<ContentModel>?
    var position : Int = 0
    @IBOutlet weak var backView: UIImageView!
    @IBOutlet weak var topTitle: UILabel!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var hyperLink: UILabel!
    @IBOutlet weak var completeBtn: UIButton!
    var type : String?
    var player : AVPlayer?
    var delegate : ReloadSubCatInterface?
    @IBOutlet weak var nextBtn: UIView!
    @IBOutlet weak var nextBtnText: UILabel!
    
    
    
   
    var count =  0
    
    
    
    override func viewDidLoad() {
        
        guard let contentModels = contentModels, delegate != nil else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
                
            }
            return
        }
        
   
        nextBtn.layer.cornerRadius = 4
        nextBtn.isUserInteractionEnabled = true
        nextBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(nextBtnClicked)))
     
        
        if type == "Informations" {
            mainCompletedBtn.isHidden = true
        }
        
      
        completeBtn.layer.cornerRadius = 8
        
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
        
        let contentModel = contentModels[position]
        loadUI(contentModel: contentModel)
        
    }
    
    
    func loadUI(contentModel : ContentModel){
        
        if contentModel.multiVideoModels!.count == 0 {
            nextBtn.isHidden = true
        }
        else if contentModel.multiVideoModels!.count == 1 {
            if self.contentModels!.count  == (position + 1) {
                nextBtn.isHidden = true
            }
            else {
                nextBtnText.text = "Session \(position + 2)"
            }
            
           
        }
        else {
            nextBtnText.text = "Video 2"
        }
        
        Firestore.firestore().collection(checkUserOrNavy() == "user" ? "Users" : "NavyMembers").document(UserModel.data!.uid ?? "123").collection("NavyCompleted").document(contentModel.id!).getDocument { snapshot, error in
            if let snapshot = snapshot, snapshot.exists {
                self.completeBtn.setTitle("Completed", for: .normal)
                self.completeBtn.setTitleColor(.white, for: .normal)
                self.completeBtn.backgroundColor = UIColor(red: 75/255, green: 181/255, blue: 67/255, alpha: 1)
                self.completeBtn.isUserInteractionEnabled = false
                self.completeBtn.isEnabled = false
                
            }
        }
        
        topTitle.text = contentModel.title ?? ""
        
        if contentModel.pdfLink != nil {
            self.webView.isHidden = false
            self.progressView.isHidden = false
            webView.uiDelegate  =  self
            webView.navigationDelegate = self
            progressView.progress = 0.0
            webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
            webView.addSubview(progressView)
        }
        else {
          
            
            self.webView.isHidden = true
            self.progressView.isHidden = true
           
    
        }
        view.layoutIfNeeded()
        
        if !contentModel.multiVideoModels!.isEmpty{
            
            videoView.isUserInteractionEnabled = true
            videoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(videoViewClick)))
            
            self.videoView.isHidden = false
            
            playVideo(multiVideoModel: contentModel.multiVideoModels![0])
          
        }
        else {
            videoView.isHidden = true
        }
        
        if let mhyperLink = contentModel.hyperLink, !mhyperLink.isEmpty {
            hyperLink.isHidden = false
            hyperLinkView.isHidden = false
            hyperLink.text = mhyperLink
            hyperLink.isUserInteractionEnabled = true
            hyperLink.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hyperLinkClick)))
        }
        else {
            hyperLink.isHidden = true
            hyperLinkView.isHidden = true
        }
        
        DispatchQueue.main.async {
            if let pdfLink = contentModel.pdfLink {
                let urls = URL(string:pdfLink)
                let request = URLRequest(url: urls!)
                self.webView.load(request)
            }
        }
    }
  
    
    @objc func nextBtnClicked(){
        
        if contentModels!.count > (position + 1) && contentModels![position].multiVideoModels!.count == (count + 1) {
            count = 0
            position = position + 1
            self.showToast(message: "Session : \(position + 1)")
            loadUI(contentModel: contentModels![position])
           
            
        }
        else if contentModels!.count >= (position + 1) &&  contentModels![position].multiVideoModels!.count > (count + 1) {
            
            count = count + 1
            if count == (contentModels![position].multiVideoModels!.count - 1) {
                if self.contentModels!.count > (position + 1) {
                    self.nextBtnText.text = "Session \(position + 2)"
                }
                else {
                    self.nextBtn.isHidden = true
                }
             
            }
            else {
                self.nextBtnText.text = "Video \(count + 2)"
            }
            self.showToast(message: "Video : \(count + 1)")
            self.playVideo(multiVideoModel: contentModels![position].multiVideoModels![count])
        }
        else {
            self.nextBtn.isHidden = true
        }
    }
    
    func playVideo(multiVideoModel : MultiVideoModel) {
       
        player?.pause()
        
         player = AVPlayer()
         player?.volume = 0.6
         NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidPlayToEndTime), name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
         
           
        
      
             if let orientation = multiVideoModel.ratio {
                 let newConstraint = self.videoRatio.constraintWithMultiplier(orientation)
                 videoView.removeConstraint(videoRatio)
                 videoView.addConstraint(newConstraint)
                 self.videoView.layoutIfNeeded()
                 self.videoRatio = newConstraint
        
                 self.videoView.layoutIfNeeded()
             }
        
        if let url = URL(string: Constants.AWS_ROYAL_URL+"/"+multiVideoModel.videoURL!) {
             if let videoData = SDImageCache.shared.diskImageData(forKey: url.absoluteString) {
                 let documentsDirectoryURL = FileManager.default.urls(
                     for: .documentDirectory,
                     in: .userDomainMask
                 ).first!
                 let fileURL = documentsDirectoryURL.appendingPathComponent(url.lastPathComponent)

                 try? videoData.write(to: fileURL, options: .atomic)

                 let playerItem = AVPlayerItem(url: fileURL)
                 player?.replaceCurrentItem(with: playerItem)
             
                 // Setup your player view and play the video.
             } else {
             
                 downloadMP4File(from: url)
                 // Continue to play online while downloading for cache
                 let playerItem = AVPlayerItem(url: url)
                  player?.replaceCurrentItem(with: playerItem)
             }

             let playerLayer = AVPlayerLayer(player: player)
             playerLayer.videoGravity = .resizeAspect
             playerLayer.frame = self.videoView.bounds
             self.videoView.layer.addSublayer(playerLayer)
             
         }
         
         player?.play()
    }
    
    @objc func playerItemDidPlayToEndTime(notification: Notification) {
        nextBtnClicked()
    }

    @objc func videoViewClick(){
  
       
        self.player?.pause()
        let playerViewController = AVPlayerViewController()
        let newPlayer  = AVPlayer(playerItem: self.duplicatePlayerItem(originalItem: self.player!.currentItem!))
        newPlayer.seek(to: self.player!.currentTime())
        playerViewController.player = newPlayer
        
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
    func duplicatePlayerItem(originalItem: AVPlayerItem) -> AVPlayerItem? {
        if let asset = originalItem.asset as? AVURLAsset {
            return AVPlayerItem(url: asset.url)
        }
        // Handle non-URL-based assets or return nil if necessary
        return nil
    }
    
    @objc func hyperLinkClick(){
        if let hyperLinkId = contentModels![position].hyperLinkId {

            Firestore.firestore().collection(checkUserOrNavy() == "user" ? "Workouts" : "AdminWorkouts").document(hyperLinkId).getDocument { snapshot, error in
                if let snapshot = snapshot, snapshot.exists {
                    if let catModel = try? snapshot.data(as: CategoryModel.self) {
                        self.dismiss(animated: true) {
                            self.delegate!.reloadSubCat(type: self.checkUserOrNavy() == "user" ? "Workouts" : "AdminWorkouts", catName: catModel.title, catId: catModel.id)
                        }
                       
                    }
                    
                }
            }
            
            Firestore.firestore().collection(checkUserOrNavy() == "user" ? "Informations" : "AdminInformations").document(hyperLinkId).getDocument { snapshot, error in
                if let snapshot = snapshot, snapshot.exists {
                    if let catModel = try? snapshot.data(as: CategoryModel.self) {
                        self.dismiss(animated: true) {
                            self.delegate!.reloadSubCat(type: self.checkUserOrNavy() == "user" ? "Informations" : "AdminInformations", catName: catModel.title, catId: catModel.id)
                        }
                    }
                    
                }
            }
        }
    
    }
    
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            self.progressView.alpha = 1.0
            progressView.setProgress(Float(webView.estimatedProgress), animated: true)
            if webView.estimatedProgress >= 1.0 {
                UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseInOut, animations: {
                    self.progressView.alpha = 0.0
                }) { (BOOL) in
                    self.progressView.progress = 0
                }
                
            }
            
        }
    }
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "badgeEarnSeg" {
            if let VC = segue.destination as? BadgeEarnController {
                if let badge = sender as? String {
                    VC.badge = badge
                }
            }
        }
    }
    @objc func backViewClicked(){
        self.dismiss(animated: true)
    }
    
    @IBAction func completeBtnClicked(_ sender: Any) {
        let alert = UIAlertController(title: "Confirm", message: "Do you want to mark this session as a completed?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.completeBtn.setTitle("Completed", for: .normal)
            self.completeBtn.setTitleColor(.white, for: .normal)
            self.completeBtn.backgroundColor = UIColor(red: 75/255, green: 181/255, blue: 67/255, alpha: 1)
            self.showToast(message: "Completed")
            self.completeBtn.isUserInteractionEnabled = false
            self.completeBtn.isEnabled = false
            Firestore.firestore().collection(self.checkUserOrNavy() == "user" ? "Users" : "NavyMembers").document(UserModel.data!.uid ?? "123").collection("NavyCompleted").document(self.contentModels![self.position].id!).setData(["id" : self.contentModels![self.position].id!]) { error in
                let query = Firestore.firestore().collection(self.checkUserOrNavy() == "user" ? "Users" : "NavyMembers").document(UserModel.data!.uid!).collection("NavyCompleted")
                let watchQuery = query.count
              
                    watchQuery.getAggregation(source: .server) { snapshot, error in
                  
                        if let snapshot = snapshot {
                            let count = snapshot.count
                            
                            if count == 3 {
                                self.performSegue(withIdentifier: "badgeEarnSeg", sender: "BRONZE")
                            }
                            else if count == 9 {
                                self.performSegue(withIdentifier: "badgeEarnSeg", sender: "SILVER")
                            }
                            else if count == 18 {
                                self.performSegue(withIdentifier: "badgeEarnSeg", sender: "GOLD")
                            }
                            else if count == 36 {
                                self.performSegue(withIdentifier: "badgeEarnSeg", sender: "PLATINUM")
                            }
                            
                        }
                    }
            }
    
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}
