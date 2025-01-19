//
//  ScanQRCodeController.swift
//  Royal Australian Navy Fitness
//
//  Created by Vijay Rathore on 11/01/24.
//

import UIKit
import Lottie
import Firebase
import AVFoundation

class RoyalScanQRCodeController : UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var captureSession = AVCaptureSession()

    @IBOutlet weak var animationView: LottieAnimationView!
    @IBOutlet weak var scannerView: UIView!
    var isProcessingQRCode = false // Flag to track QR code processing
    var videoPreviewLayer : AVCaptureVideoPreviewLayer?
    private let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
                                      AVMetadataObject.ObjectType.code39,
                                      AVMetadataObject.ObjectType.code39Mod43,
                                      AVMetadataObject.ObjectType.code93,
                                      AVMetadataObject.ObjectType.code128,
                                      AVMetadataObject.ObjectType.ean8,
                                      AVMetadataObject.ObjectType.ean13,
                                      AVMetadataObject.ObjectType.aztec,
                                      AVMetadataObject.ObjectType.pdf417,
                                      AVMetadataObject.ObjectType.itf14,
                                      AVMetadataObject.ObjectType.dataMatrix,
                                      AVMetadataObject.ObjectType.interleaved2of5,
                                      AVMetadataObject.ObjectType.qr]
 
    
   
    let sessionQueue = DispatchQueue(label: "sessionQueue")

    override func viewDidLoad() {

     
        NotificationCenter.default.addObserver(self, selector: #selector(self.update), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.update), name: UIApplication.didBecomeActiveNotification, object: nil)
    
        // Get the back-facing camera for capturing videos
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
            print("Failed to get the camera device")
            return
        }
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Set the input device on the capture session.
            captureSession.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
//            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
        
        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = scannerView.layer.bounds
        videoPreviewLayer?.cornerRadius = 16
        scannerView.layer.addSublayer(videoPreviewLayer!)
        
        // Start video capture.
        update()
    }

    @objc func update() {
        
        sessionQueue.async {
            self.captureSession.startRunning()
        }
        animationView.contentMode = .scaleAspectFit
         
         // 2. Set animation loop mode
        animationView.loopMode = .loop
        
         // 3. Adjust animation speed
        animationView.animationSpeed = 0.5
         
         // 4. Play animation
        animationView.play()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        sessionQueue.async {
            self.captureSession.startRunning()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        sessionQueue.async {
            self.captureSession.stopRunning()
        }
    }

    
    private func updatePreviewLayer(layer: AVCaptureConnection, orientation: AVCaptureVideoOrientation) {
      layer.videoOrientation = orientation
      videoPreviewLayer?.frame = self.scannerView.bounds
    }
    
    override func viewDidLayoutSubviews() {
      super.viewDidLayoutSubviews()
      
      if let connection =  self.videoPreviewLayer?.connection  {
        let currentDevice: UIDevice = UIDevice.current
        let orientation: UIDeviceOrientation = currentDevice.orientation
        let previewLayerConnection : AVCaptureConnection = connection
        
        if previewLayerConnection.isVideoOrientationSupported {
          switch (orientation) {
          case .portrait:
            updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
            break
          case .landscapeRight:
            updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeLeft)
            break
          case .landscapeLeft:
            updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeRight)
            break
          case .portraitUpsideDown:
            updatePreviewLayer(layer: previewLayerConnection, orientation: .portraitUpsideDown)
            break
          default:
            updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
            break
          }
        }
      }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectWorkoutSeg" {
            if let VC = segue.destination as? RoyalSelectWorkouViewController {
                if let sGym = sender as? String {
                    VC.sGym = sGym
                }
            }
        }
    }
 
    func checkQRCode(value: String) {
        ProgressHUDShow(text: "")
        Firestore.firestore().collection("Gyms").document(value).getDocument { snapshot, error in
            self.ProgressHUDHide()
            self.isProcessingQRCode = false // Reset the flag
            
            if let snapshot = snapshot, snapshot.exists {
                if Constants.isNavyCheckedIn {
                    Constants.isNavyCheckedIn = false
                    self.addCheckInOut(gymName: value, checkInTime: Constants.checkedInTime, CheckOutTime: Date())
                } else {
                    Constants.isNavyCheckedIn = true
                    Constants.gymName = value
                    Constants.checkedInTime = Date()
                }
                
                let alert = UIAlertController(title: Constants.isNavyCheckedIn ? "You have checked in" : "You have checked out", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    self.beRootScreen(mIdentifier: Constants.StroyBoard.navyTabBarViewController)
                }))
                self.present(alert, animated: true)
            } else {
                let alert = UIAlertController(title: "", message: "Invalid QR CODE", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (alertA) in
                    self.isProcessingQRCode = false // Reset the flag
                    self.sessionQueue.async {
                        self.captureSession.startRunning()
                    }
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            scannerView.frame = CGRect.zero
            
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedCodeTypes.contains(metadataObj.type) {
            // If the found metadata is equal to the QR code metadata (or barcode) then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            scannerView.frame = barCodeObject!.bounds
          
            if metadataObj.stringValue != nil {
                      if !isProcessingQRCode {
                          isProcessingQRCode = true // Set the flag to true
                          
                          sessionQueue.async {
                              self.captureSession.stopRunning()
                          }
                          
                          let value = metadataObj.stringValue ?? ""
                          if !value.isEmpty {
                              self.checkQRCode(value: value)
                          } else {
                              let alert = UIAlertController(title: "", message: "Invalid QR CODE", preferredStyle: UIAlertController.Style.alert)
                              alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (alertA) in
                                  self.isProcessingQRCode = false // Reset the flag
                                  self.captureSession.startRunning()
                              }))
                              self.present(alert, animated: true, completion: nil)
                          }
                      }
                  }
                
           
        }
        
    }
}
