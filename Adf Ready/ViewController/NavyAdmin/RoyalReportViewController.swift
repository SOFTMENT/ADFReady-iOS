//
//  ReportViewController.swift
//  Royal Australian Navy Fitness
//
//  Created by Vijay Rathore on 01/12/23.
//

import UIKit

class RoyalReportViewController : UIViewController {
    @IBOutlet weak var registrationReport: UIButton!
    @IBOutlet weak var gymReport: UIButton!
    @IBOutlet weak var navyRegistrationReport: UIButton!
    @IBOutlet weak var backView: UIImageView!
    
    var accountType : ACCOUNT_TYPE?
    override func viewDidLoad() {
        
        guard let accountType = accountType else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }
        
        
        if accountType == .PREJOINER {
            gymReport.isHidden = true
            registrationReport.isHidden = false
            navyRegistrationReport.isHidden = true
        }
        else {
            gymReport.isHidden = false
            registrationReport.isHidden = true
            navyRegistrationReport.isHidden = false
        }
        
        gymReport.layer.cornerRadius = 8
        registrationReport.layer.cornerRadius = 8
        navyRegistrationReport.layer.cornerRadius = 8
       
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
       
    }
    @objc func backViewClicked() {
        self.dismiss(animated: true)
    }
    @IBAction func navyRegistrationClicked(_ sender: Any) {
        var collectionName = "Users"
        if accountType == .NAVY {
            collectionName = "NavyMembers"
        }
        
        
        let alert = UIAlertController(title: nil, message: "Choose Duration", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Monthly", style: .default, handler: { action in
           
            let (firstDay, lastDay) = self.firstAndLastDayOfTheMonth()
            self.fetchUsers(collectionName: collectionName, mFileName: self.monthYearString(), startDate: firstDay, endDate: lastDay, isLifetime: false)
        }))
        alert.addAction(UIAlertAction(title: "Yearly", style: .default, handler: { action in
            let (firstDay, lastDay) = self.firstAndLastDayOfTheYear()
            self.fetchUsers(collectionName: collectionName, mFileName: self.yearString(), startDate: firstDay, endDate: lastDay, isLifetime: false)

        }))
        alert.addAction(UIAlertAction(title: "Lifetime", style: .default, handler: { action in
            
            self.fetchUsers(collectionName: collectionName, mFileName: "Overall", startDate: Date(), endDate: Date(), isLifetime: true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    @IBAction func registrationReportClicked(_ sender: Any) {
        var collectionName = "Users"
        if accountType == .NAVY {
            collectionName = "NavyMembers"
        }
        let alert = UIAlertController(title: nil, message: "Choose Duration", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Monthly", style: .default, handler: { action in
           
            let (firstDay, lastDay) = self.firstAndLastDayOfTheMonth()
            self.fetchUsers(collectionName: collectionName, mFileName: self.monthYearString(), startDate: firstDay, endDate: lastDay, isLifetime: false)
        }))
        alert.addAction(UIAlertAction(title: "Yearly", style: .default, handler: { action in
            let (firstDay, lastDay) = self.firstAndLastDayOfTheYear()
            self.fetchUsers(collectionName: collectionName, mFileName: self.yearString(), startDate: firstDay, endDate: lastDay, isLifetime: false)

        }))
        alert.addAction(UIAlertAction(title: "Lifetime", style: .default, handler: { action in
            
            self.fetchUsers(collectionName: collectionName, mFileName: "Overall", startDate: Date(), endDate: Date(), isLifetime: true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    
    }
    func fetchUsers(collectionName : String,mFileName : String,startDate : Date, endDate : Date, isLifetime : Bool){
        
        
        let alert = UIAlertController(title: nil, message: "Order By", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Name", style: .default, handler: { action in
            self.ProgressHUDShow(text: "")
            self.getAllRoyalUsers(collectionName: collectionName, startDate: startDate, endDate: endDate, isLifetime: isLifetime, orderBy: "name", completion: { users in
                self.ProgressHUDHide()
                self.createCSVForRegistration(mFileName: mFileName, from: users ?? [])
            })
        }))
        
        alert.addAction(UIAlertAction(title: "Registration Date", style: .default, handler: { action in
            self.ProgressHUDShow(text: "")
            self.getAllRoyalUsers(collectionName: collectionName, startDate: startDate, endDate: endDate, isLifetime: isLifetime, orderBy: "date", completion: { users in
                self.ProgressHUDHide()
                self.createCSVForRegistration(mFileName: mFileName, from: users ?? [])
            })

        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    func monthYearString()->String{
        let date = Date() // Current date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMMyyyy" // "MMMM" for full month name, "yyyy" for four-digit year
        return dateFormatter.string(from: date)
    }
    func yearString()->String{
        let date = Date() // Current date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy" // "MMMM" for full month name, "yyyy" for four-digit year
        return dateFormatter.string(from: date)
    }
    
    func createCSVForRegistration(mFileName : String, from users: Array<UserModel>) {
        var csvString = "User ID, Full Name, Email, Registration Date\n"
        
        for user in users {
            let dateString = DateFormatter.localizedString(from: user.date!, dateStyle: .short, timeStyle: .short)
            let csvLine = "\(user.uid!), \(user.fullName!), \(user.email!), \(dateString)\n"
            csvString.append(contentsOf: csvLine)
        }
        
        writeCSVToFile(mFileName: mFileName, csvString: csvString)
    }
    func shareCSVFile(at filePath: URL, from viewController: UIViewController) {
        let activityViewController = UIActivityViewController(activityItems: [filePath], applicationActivities: nil)
        
        // For iPad, you need to present it as a popover
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = viewController.view
            // Configure the position of the popover
            popoverController.sourceRect = CGRect(x: viewController.view.bounds.midX, y: viewController.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        viewController.present(activityViewController, animated: true, completion: nil)
    }
    func writeCSVToFile(mFileName : String, csvString: String) {
        let fileName = "\(mFileName).csv"
        let path = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)

        do {
            try csvString.write(to: path, atomically: true, encoding: String.Encoding.utf8)
            self.shareCSVFile(at: path, from: self)
        } catch {
            print("Error writing CSV file: \(error)")
        }
    }
    
    @IBAction func gymReportClicked(_ sender: Any) {
        fetchCheckInOuts()
    }
    
    func fetchCheckInOuts(){
        
        self.ProgressHUDShow(text: "")
        self.getAllCheckInOut { categories in
            self.ProgressHUDHide()
            if let categories = categories, categories.count > 0 {
                self.createCSVForCheckInOut(from: categories)
            }
            else {
                self.showToast(message: "No data found")
            }
        }
    }
    
  
    func createCSVForCheckInOut(from checkInOuts: Array<CheckInOutModel>) {
        var csvString = "Full Name, Email, Gym Name, CheckIn Time, CheckOut Time\n"
        
        for checkInOut in checkInOuts {
           
            let csvLine = "\(checkInOut.name!), \(checkInOut.email!), \(checkInOut.gymName ?? "Nil"), \(self.convertDateForVoucher(checkInOut.checkIn!)), \(self.convertDateForVoucher(checkInOut.checkOut!))\n"
            csvString.append(contentsOf: csvLine)
        }
        
        writeCSVToFile(mFileName: "GymReports", csvString: csvString)
    }
    
}

