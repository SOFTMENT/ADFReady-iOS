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
    
    static var services = ["Undecided","Navy", "Army", "Airforce"]
    static var genders = ["Male", "Female","No Answer"]
    static var ageRange = ["Under 20", "21-30", "31-40", "41-50", "50+"]
    static var reasonForDownloading = ["I am joining ADF", "I am thinking of joining ADF", "I am to try ADF ready fitness program","Other"]
    static var states = [
      "New South Wales",
      "Queensland",
      "South Australia",
      "Tasmania",
      "Victoria",
      "Western Australia"
    ];

    
    struct StroyBoard {
        
        static let continueASViewController = "continueAsVC"
        static let tabBarViewController = "tabbarVC"
        static let serviceViewController = "serviceVC"
      
    }

}
