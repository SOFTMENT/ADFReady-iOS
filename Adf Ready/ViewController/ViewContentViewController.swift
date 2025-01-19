//
//  ViewContentViewController.swift
//  Adf Ready
//
//  Created by Vijay Rathore on 17/11/24.
//

import UIKit
import WebKit
import AVFoundation
import Firebase
import AVKit
import SDWebImage

class ViewContentViewController : UIViewController, WKUIDelegate,WKNavigationDelegate  {
  
    @IBOutlet weak var videoRatio: NSLayoutConstraint!
    @IBOutlet weak var mainCompletedBtn: UIView!
    var contentModels : Array<ContentModel>?
    var position : Int = 0
    @IBOutlet weak var backView: UIImageView!
    @IBOutlet weak var topTitle: UILabel!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var completeBtn: UIButton!
    var type : String?
    var player : AVPlayer?
    
   
    @IBOutlet weak var nextBtn: UIView!
    @IBOutlet weak var nextBtnText: UILabel!
    
    
    
   
    var count =  0
    
    
    
   
    
    override func viewWillAppear(_ animated: Bool) {
        guard let contentModels = contentModels else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
                
            }
            return
        }
        
        nextBtn.layer.cornerRadius = 4
        nextBtn.isUserInteractionEnabled = true
        nextBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(nextBtnClicked)))
     
        
        if type != "\(UserModel.data!.service!)Workouts"  {
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
        
        
//        Firestore.firestore().collection("Users").document(UserModel.data!.uid ?? "123").collection("Completed").document(contentModel.id!).getDocument { snapshot, error in
//            if let snapshot = snapshot, snapshot.exists {
//                self.completeBtn.setTitle("Completed", for: .normal)
//                self.completeBtn.setTitleColor(.white, for: .normal)
//                self.completeBtn.backgroundColor = UIColor(red: 75/255, green: 181/255, blue: 67/255, alpha: 1)
//                self.completeBtn.isUserInteractionEnabled = false
//                self.completeBtn.isEnabled = false
//                
//            }
//        }
        
        topTitle.text = contentModel.title ?? ""
        
      
        view.layoutIfNeeded()
        
        DispatchQueue.main.async {
            if let pdfLink = contentModel.pdfLink {
                self.webView.isHidden = false
                self.progressView.isHidden = false
                self.webView.uiDelegate  =  self
                self.webView.navigationDelegate = self
                self.progressView.progress = 0.0
                self.webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
                self.webView.addSubview(self.progressView)
                let urls = URL(string:pdfLink)
                let request = URLRequest(url: urls!)
                self.webView.load(request)
            }
            else {
                self.webView.isHidden = true
                self.progressView.isHidden = true
            }
           
        }
        if !contentModel.multiVideoModels!.isEmpty{
            
            videoView.isUserInteractionEnabled = true
            videoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(videoViewClick)))
            
            self.videoView.isHidden = false
            
            playVideo(multiVideoModel: contentModel.multiVideoModels![0])
          
        }
        else {
            videoView.isHidden = true
        }
        
       
        
      
    }
  
    
    @objc func nextBtnClicked(){
        print("CONTENT MODEL COUNT ",contentModels!.count);
        print("---------")
        print("MULTIMODEL COUNT ",contentModels![position].multiVideoModels!.count);
        
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
    @IBAction func completeBtnClicked(_ sender: Any) {
        let alert = UIAlertController(title: "Confirm", message: "Do you want to mark this session as a completed?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
//            self.completeBtn.setTitle("Completed", for: .normal)
//            self.completeBtn.setTitleColor(.white, for: .normal)
//            self.completeBtn.backgroundColor = UIColor(red: 75/255, green: 181/255, blue: 67/255, alpha: 1)
//            self.showToast(message: "Completed")
//            self.completeBtn.isUserInteractionEnabled = false
//            self.completeBtn.isEnabled = false
            
            
            self.showToast(message: "Session Completed")
            Firestore.firestore().collection("Users").document(UserModel.data!.uid ?? "123").setData(["sessionCompleted" : FieldValue.increment(Int64(1))], merge: true)
            Firestore.firestore().collection("Users").document(UserModel.data!.uid ?? "123").collection("Completed").document(self.contentModels![self.position].id!).setData(["id" : self.contentModels![self.position].id!]) { error in
               
            }
    
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
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
        
        if let url = URL(string: Constants.AWS_BASE_URL+"/"+multiVideoModel.videoURL!) {
            
                 let playerItem = AVPlayerItem(url: url)
                  player?.replaceCurrentItem(with: playerItem)
          
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
    
 
    @objc func backViewClicked(){
        self.dismiss(animated: true)
    }
    
 
}
