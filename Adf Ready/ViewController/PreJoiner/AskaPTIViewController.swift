//
//  AskaPTIViewController.swift
//  Royal Australian Navy
//
//  Created by Vijay Rathore on 16/10/23.
//

import UIKit
import MessageUI

class AskaPTIViewController : UIViewController, MFMailComposeViewControllerDelegate {
    @IBOutlet weak var mTextView: UITextView!
    @IBOutlet weak var sendBtn: UIButton!
    let placeholderText = "Type your question here..."
    
    override func viewDidLoad() {
        sendBtn.layer.cornerRadius = 8
        mTextView.textColor = UIColor.lightGray
        mTextView.text = placeholderText
        mTextView.layer.cornerRadius = 8
        mTextView.delegate = self
        mTextView.contentInset = UIEdgeInsets(top: 6, left: 5, bottom: 6, right: 6)
    }
    
    @IBAction func sendBtnClicked(_ sender: Any) {
        let question = mTextView.text
        
        if question == "" || question == "Type your question here..."{
            self.showToast(message: "Enter Question")
        }
        else {
           
          
            sendEmail(body: question!)
            
        }
    }
    
    func sendEmail(body : String) {
        if MFMailComposeViewController.canSendMail() {
            self.mTextView.text = ""
           
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["pcp.corro@outlook.com"]) // Add your friend's email address here
            mail.setSubject("Ask a PTI") // Add your subject
            mail.setMessageBody(body, isHTML: false) // Set the email body

            present(mail, animated: true)
        } else {
            // Show an error or alert to the user
            print("This device cannot send email")
        }
    }
    

    // Implement the mail compose controller delegate method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if error == nil{
            self.showToast(message: "Email has been sent.")
        }
        
        controller.dismiss(animated: true)
    }
}

extension AskaPTIViewController : UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.text == placeholderText {
            textView.textColor = UIColor.darkGray
            textView.text = ""
        }
        return true
    }

    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.textColor = UIColor.lightGray
            textView.text = placeholderText
        }
    }
}
