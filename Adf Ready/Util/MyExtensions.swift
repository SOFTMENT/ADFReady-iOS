//
//  MyExtensions.swift
//  Adf Ready
//
//  Created by Vijay Rathore on 16/11/24.
//

//
//  MyExtensions.swift
//  Royal Australian Navy
//
//  Created by Vijay Rathore on 15/10/23.
//


import UIKit
import MBProgressHUD
import TTGSnackbar
import Firebase
import FirebaseFirestoreSwift
import PassKit
import FirebaseFunctions
import SDWebImage
import AVFoundation




extension UIStoryboard {
    class func load(_ identifier: String) -> UIViewController {
        UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: identifier)
    }
}

extension UITextField {
  
    func setPlaceholderColor(_ color: UIColor) {
          guard let placeholder = self.placeholder else { return }
          self.attributedPlaceholder = NSAttributedString(
              string: placeholder,
              attributes: [NSAttributedString.Key.foregroundColor: color]
          )
        backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.7)
      }
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        
        self.rightView = paddingView
        self.rightViewMode = .always
        
    }
    
    func changePlaceholderColour()  {
        attributedPlaceholder = NSAttributedString(string: placeholder ?? "",
                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)])
    }
    
    func addBorder() {
        layer.borderWidth = 1
        layer.borderColor = UIColor(red: 221/255, green: 221/255, blue: 221/255, alpha: 1).cgColor
        setLeftPaddingPoints(10)
        setRightPaddingPoints(10)
    }
    
    
    /// set icon of 20x20 with left padding of 8px
    func setLeftIcons(icon: UIImage) {
        
        let padding = 8
        let size = 20
        
        let outerView = UIView(frame: CGRect(x: 0, y: 0, width: size+padding, height: size) )
        let iconView  = UIImageView(frame: CGRect(x: padding, y: 0, width: size, height: size))
        iconView.image = icon
        outerView.addSubview(iconView)
        
        leftView = outerView
        leftViewMode = .always
    }
    
    
    
    
    /// set icon of 20x20 with left padding of 8px
    func setRightIcons(icon: UIImage) {
        
        let padding = 8
        let size = 16
        
        let outerView = UIView(frame: CGRect(x: 0, y: 0, width: size+padding, height: size) )
        let iconView  = UIImageView(frame: CGRect(x: -padding, y: 0, width: size, height: size))
        iconView.image = icon
        outerView.addSubview(iconView)
        
        rightView = outerView
        rightViewMode = .always
    }
    
}

extension Date {
    
   
 
    func timeAgoSinceDate() -> String {
        
        // From Time
        let fromDate = self
        
        // To Time
        let toDate = Date()
        
        // Estimation
        // Year
        if let interval = Calendar.current.dateComponents([.year], from: fromDate, to: toDate).year, interval > 0  {
            
            return interval == 1 ? "\(interval)" + " " + "year ago" : "\(interval)" + " " + "years ago"
        }
        
        // Month
        if let interval = Calendar.current.dateComponents([.month], from: fromDate, to: toDate).month, interval > 0  {
            
            return interval == 1 ? "\(interval)" + " " + "month ago" : "\(interval)" + " " + "months ago"
        }
        
        // Day
        if let interval = Calendar.current.dateComponents([.day], from: fromDate, to: toDate).day, interval > 0  {
            
            return interval == 1 ? "\(interval)" + " " + "day ago" : "\(interval)" + " " + "days ago"
        }
        
        // Hours
        if let interval = Calendar.current.dateComponents([.hour], from: fromDate, to: toDate).hour, interval > 0 {
            
            return interval == 1 ? "\(interval)" + " " + "hour ago" : "\(interval)" + " " + "hours ago"
        }
        
        // Minute
        if let interval = Calendar.current.dateComponents([.minute], from: fromDate, to: toDate).minute, interval > 0 {
            
            return interval == 1 ? "\(interval)" + " " + "minute ago" : "\(interval)" + " " + "minutes ago"
        }
        
        return "a moment ago"
    }
}



extension UIViewController {
 
    
  
    func makeValidURL(urlString: String) -> String {
        let urlHasHttpPrefix = urlString.hasPrefix("http://")
        let urlHasHttpsPrefix = urlString.hasPrefix("https://")
        return (urlHasHttpPrefix || urlHasHttpsPrefix) ? urlString : "http://\(urlString)"
    }


    func showToast(message : String) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 115, y: self.view.frame.size.height/2, width: 240, height: 36))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = UIFont(name: "Roboto-Regular", size: 14)
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 5.0, delay: 0.1, options: .curveEaseIn, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
  
    func convertSecondstoMinAndSec(totalSeconds : Int) -> String{
     
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60

        return String(format: "%02i : %02i", minutes, seconds)

    }
    func ProgressHUDShow(text : String) {
        let loading = MBProgressHUD.showAdded(to: self.view, animated: true)
        loading.mode = .indeterminate
        loading.label.text =  text
        loading.label.font = UIFont(name: "Roboto-Regular", size: 11)
    }
    
    func ProgressHUDHide(){
        MBProgressHUD.hide(for: self.view, animated: true)
    }
    
    func downloadMP4File(from videoURL: URL) {
        
        print(videoURL)
        let task = URLSession.shared.dataTask(with: videoURL) { data, _, error in
            guard let videoData = data, error == nil else {
                print("Error downloading video:", error ?? "Unknown error")
                return
            }

            // Store the downloaded video data to SDWebImage's cache
            SDImageCache.shared.storeImageData(toDisk: videoData, forKey: videoURL.absoluteString)
        }
        task.resume()
    }
    
    
    func getUserData(uid : String, showProgress : Bool)  {
        
        
        if showProgress {
            ProgressHUDShow(text: "")
        }
        
        Firestore.firestore().collection("Users").document(uid).getDocument(completion: { snapshot, error in
            
            
            
            if error != nil {
                if showProgress {
                    self.ProgressHUDHide()
                }
                self.showError(error!.localizedDescription)
            }
            else {
                
                if let snapshot = snapshot, snapshot.exists {
                    
                    
                    
                    if let user = try? snapshot.data(as: UserModel.self) {
                        
                        
                        
                        UserModel.data = user
                        
                        if user.service == nil {
                            self.beRootScreen(mIdentifier: Constants.StroyBoard.serviceViewController)
                        }
                        else {
                            self.beRootScreen(mIdentifier: Constants.StroyBoard.tabBarViewController)
                        }
                        
                       
                
                    }
                    else {
                        
                        DispatchQueue.main.async {
                            self.beRootScreen(mIdentifier: Constants.StroyBoard.continueASViewController)
                        }
                    }
                }
            }
        })
    }
    
                                                                
    func addYearToDate(years : Int, currentDate : Date) -> Date{
        var dayComponent    = DateComponents()
        dayComponent.year   = years
        let theCalendar     = Calendar.current
        let nextDate        = theCalendar.date(byAdding: dayComponent, to: currentDate)
        return nextDate ?? Date()
    }
    
    
  


func navigateToAnotherScreen(mIdentifier : String)  {
    
    let destinationVC = getViewControllerUsingIdentifier(mIdentifier: mIdentifier)
    destinationVC.modalPresentationStyle = .fullScreen
    present(destinationVC, animated: true) {
        
    }
}

func myPerformSegue(mIdentifier : String)  {
    performSegue(withIdentifier: mIdentifier, sender: nil)
    
}

    func checkUserOrNavy() ->String {
        let standard = UserDefaults.standard
        return standard.string(forKey: "AccountType") ?? "user"
    }
    
    
    
func getViewControllerUsingIdentifier(mIdentifier : String) -> UIViewController{
    
    let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
   
    
    switch mIdentifier {
    
    case Constants.StroyBoard.continueASViewController :
        return (storyBoard.instantiateViewController(identifier: mIdentifier) as? ContinueAsViewController)!
    case Constants.StroyBoard.serviceViewController :
        return (storyBoard.instantiateViewController(identifier: mIdentifier) as? UserTypeViewController)!
    case Constants.StroyBoard.tabBarViewController :
        return (storyBoard.instantiateViewController(identifier: mIdentifier) as? TabbarViewController)!
    
  

    default:
        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        return (storyBoard.instantiateViewController(identifier: Constants.StroyBoard.continueASViewController) as? ContinueAsViewController)!
    }
}

    
func beRootScreen(mIdentifier : String) {
    
    guard let window = self.view.window else {
        self.view.window?.rootViewController = getViewControllerUsingIdentifier(mIdentifier: mIdentifier)
        self.view.window?.makeKeyAndVisible()
        return
    }
    
    window.rootViewController = getViewControllerUsingIdentifier(mIdentifier: mIdentifier)
    window.makeKeyAndVisible()
    UIView.transition(with: window,
                      duration: 0.3,
                      options: .transitionCrossDissolve,
                      animations: nil,
                      completion: nil)
    
}




func convertDateAndTimeFormater(_ date: Date) -> String
{
    let df = DateFormatter()
    df.dateFormat = "dd-MMM-yyyy, hh:mm a"
    df.timeZone = TimeZone(abbreviation: "UTC")
    df.timeZone = TimeZone.current
    return df.string(from: date)
    
}

func convertDateFormaterWithoutDash(_ date: Date) -> String
{
    let df = DateFormatter()
    df.dateFormat = "dd MMM yyyy"
    df.timeZone = TimeZone(abbreviation: "UTC")
    df.timeZone = TimeZone.current
    return df.string(from: date)
    
}

func convertDateFormater(_ date: Date) -> String
{
    let df = DateFormatter()
    df.dateFormat = "dd-MMM-yyyy"
    df.timeZone = TimeZone(abbreviation: "UTC")
    df.timeZone = TimeZone.current
    return df.string(from: date)
    
}

func convertDateFormaterWithSlash(_ date: Date) -> String
{
    let df = DateFormatter()
    df.dateFormat = "dd/MM/yy"
    df.timeZone = TimeZone(abbreviation: "UTC")
    df.timeZone = TimeZone.current
    return df.string(from: date)
    
}

func convertDateForHomePage(_ date: Date) -> String
{
    let df = DateFormatter()
    df.dateFormat = "EEEE, dd MMMM"
    df.timeZone = TimeZone(abbreviation: "UTC")
    df.timeZone = TimeZone.current
    return df.string(from: date)
    
}
func convertDateForVoucher(_ date: Date) -> String
{
    let df = DateFormatter()
    df.dateFormat = "dd MMM yyyy, hh:mm a"
    df.timeZone = TimeZone(abbreviation: "UTC")
    df.timeZone = TimeZone.current
    return df.string(from: date)
    
}




func convertDateIntoTimeForRecurringVoucher(_ date: Date) -> String
{
    let df = DateFormatter()
    df.dateFormat = "hh:mm a"
    df.timeZone = TimeZone(abbreviation: "UTC")
    df.timeZone = TimeZone.current
    return "\(df.string(from: date))"
    
    
}


    func getAllCategory(type : String,completion : @escaping  (_ categories : Array<CategoryModel>?)->Void){
        Firestore.firestore().collection(type).order(by: "orderIndex").addSnapshotListener { snapshot, error in
            if let snapshot = snapshot, !snapshot.isEmpty {
                var categories = Array<CategoryModel>()
                for qdr in snapshot.documents {
                    if let categoryModel = try? qdr.data(as: CategoryModel.self) {
                        categories.append(categoryModel)
                    }
                }
                completion(categories)
            }
            else {
                completion(nil)
            }
        }
    }
    
    func getAllSubcategory(catId : String,completion : @escaping  (_ categories : Array<CategoryModel>?)->Void){
        Firestore.firestore().collection("AdminWorkouts").document(catId).collection("SubWorkouts").order(by: "orderIndex").addSnapshotListener { snapshot, error in
            if let snapshot = snapshot, !snapshot.isEmpty {
                var categories = Array<CategoryModel>()
                for qdr in snapshot.documents {
                    if let categoryModel = try? qdr.data(as: CategoryModel.self) {
                        categories.append(categoryModel)
                    }
                }
                completion(categories)
            }
            else {
                completion(nil)
            }
        }
    }
   
   
    
    func getAllSubCategory(type : String, catId : String, subId : String?,completion : @escaping  (_ contents : Array<ContentModel>?)->Void){
        var query =   Firestore.firestore().collection(type).document(catId)
        if let subId = subId {
            query  = query.collection("SubWorkouts").document(subId)
        }
        query.collection("Sub").order(by: "orderIndex").addSnapshotListener { snapshot, error in
            if let snapshot = snapshot, !snapshot.isEmpty {
                var contents = Array<ContentModel>()
                for qdr in snapshot.documents {
                    if let contentModel = try? qdr.data(as: ContentModel.self) {
                        contents.append(contentModel)
                    }
                }
                completion(contents)
            }
            else {
                completion(nil)
            }
        }
    }
    
    func getAllVideos(type : String, catId : String,subId : String?, subCatId : String,completion : @escaping  (_ contents : Array<MultiVideoModel>?)->Void){
        var query =  Firestore.firestore().collection(type).document(catId)
        if let subId = subId {
            query  = query.collection("SubWorkouts").document(subId)
        }
        query.collection("Sub").document(subCatId).collection("Videos").order(by: "orderIndex").getDocuments { snapshot, error in
            if let snapshot = snapshot, !snapshot.isEmpty {
                var contents = Array<MultiVideoModel>()
                for qdr in snapshot.documents {
                    if let contentModel = try? qdr.data(as: MultiVideoModel.self) {
                      
                        contents.append(contentModel)
                    }
                }
               
                completion(contents)
            }
            else {
              
                completion(nil)
            }
        }
    }
    


func convertDateIntoDayDigitForRecurringVoucher(_ date: Date) -> String
{
    let df = DateFormatter()
    df.dateFormat = "d"
    df.timeZone = TimeZone(abbreviation: "UTC")
    df.timeZone = TimeZone.current
    return "\(df.string(from: date))"
    
}

func convertDateForShowTicket(_ date: Date, endDate :Date) -> String
{
    let df = DateFormatter()
    df.dateFormat = "E,dd"
    df.timeZone = TimeZone(abbreviation: "UTC")
    df.timeZone = TimeZone.current
    let s = "\(df.string(from: date))-\(df.string(from: endDate))"
    df.dateFormat = "MMM yyyy"
    return "\(s) \(df.string(from: date))"
}


   

func showError(_ message : String) {
    let alert = UIAlertController(title: "ERROR", message: message, preferredStyle: .alert)
    
    let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
    
    alert.addAction(okAction)
    
    self.present(alert, animated: true, completion: nil)
    
}

func showMessage(title : String,message : String, shouldDismiss : Bool = false) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
    let okAction = UIAlertAction(title: "Ok",style: .default) { action in
        if shouldDismiss {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    
    alert.addAction(okAction)
    self.present(alert, animated: true, completion: nil)
    
}




public func logout(){

    
    do {
        try Auth.auth().signOut()
        self.beRootScreen(mIdentifier: Constants.StroyBoard.continueASViewController)
    }
    catch {
        self.beRootScreen(mIdentifier: Constants.StroyBoard.continueASViewController)
    }
}

}






extension UIImageView {
    func makeRounded() {
        
        //self.layer.borderWidth = 1
        self.layer.masksToBounds = false
        // self.layer.borderColor = UIColor.gray.cgColor
        self.layer.cornerRadius = self.frame.height / 2
        self.clipsToBounds = true
        
    }
    
    
    
    
}



extension UIView {
    
    func addBorderView() {
        layer.borderWidth = 0.8
        layer.borderColor = UIColor(red: 85/255, green: 85/255, blue: 85/255, alpha: 1).cgColor
    }
    
    func smoothShadow(){
        
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 5
        //        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
    
    func addBottomShadow() {
        layer.masksToBounds = false
        layer.shadowRadius = 2
        layer.shadowOpacity = 0.3
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOffset = CGSize(width: 0 , height: 1.8)
        layer.shadowPath = UIBezierPath(rect: CGRect(x: 0,
                                                     y: bounds.maxY - layer.shadowRadius,
                                                     width: bounds.width,
                                                     height: layer.shadowRadius)).cgPath
    }
    

    
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = .zero
        layer.shadowRadius = 2
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    func pinEdgesToSuperView() {
        guard let superView = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: superView.topAnchor).isActive = true
        leftAnchor.constraint(equalTo: superView.leftAnchor).isActive = true
        bottomAnchor.constraint(equalTo: superView.bottomAnchor).isActive = true
        rightAnchor.constraint(equalTo: superView.rightAnchor).isActive = true
    }

      
   
}







extension Double {
    func truncate(places : Int)-> Double {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}



extension NSLayoutConstraint {
    func constraintWithMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {
        NSLayoutConstraint(
            item: firstItem!,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant
        )
    }
}

