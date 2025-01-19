//
//  Constants.swift
//  Adf Ready
//
//  Created by Vijay Rathore on 16/11/24.
//

import Foundation
import UIKit
import CoreLocation


struct Constants {
    
    static var selectedTabBarPosition = 0
     static var AWS_BASE_URL = "https://adfreadybucket.s3.us-east-1.amazonaws.com"
    static var AWS_ROYAL_URL = "https://royalbucket.s3.amazonaws.com"
   
    static var isNavyCheckedIn = false
    static var gymName = ""
    static var checkedInTime = Date()
    
    static var selectedIndex = 0
 
    static let WORKOUTS = ["Boxing", "Cardio", "CrossFit", "Cycling", "HIIT", "Pilates", "Strength Training", "Swimming", "Yoga", "Zumba"]

    
    static var services = ["Undecided","Navy", "Army", "Air Force"]
    static var genders = ["Male", "Female","Non-binary"]
    static var reasonForDownloading = ["I am a Candidate.","I am thinking of Joining the ADF.","I want to be ADF Ready fit.", "Other"]
    static var states = [
        "Australian Capital Territory",
      "New South Wales",
      "Northern Territory",
      "Queensland",
      "South Australia",
      "Tasmania",
      "Victoria",
      "Western Australia"
    ];

    
    struct StroyBoard {
        
        static let entryViewController = "entryVC"
        static let royalTabBarViewController = "royaltabbarVC"
        static let adminTabBarViewController = "adminTabbarVC"
        static let navyTabBarViewController = "navyTabbarVC"
        
        static let continueASViewController = "continueAsVC"
        static let tabBarViewController = "tabbarVC"
        static let serviceViewController = "serviceVC"
        static let adminViewController = "adminVC"
        static let video1ViewController = "navyMainVC"
      
    }

}
