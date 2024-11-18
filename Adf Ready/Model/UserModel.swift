//
//  UserModel.swift
//  Adf Ready
//
//  Created by Vijay Rathore on 16/11/24.
//

import UIKit
import Foundation


class UserModel: NSObject, Codable {
    
    var fullName : String?
    var email : String?
    var uid : String?
    var createDate : Date?
    var profilePic : String?
    var gender : String?
    var ageGroup : String?
    var state : String?
    var reasonForDownload : String?
    var service : String?
    
    
    static func clean() {
        userModel = nil
    }
    
    private static var userModel : UserModel?
     
      static var data : UserModel? {
          set(userData) {
              if userModel == nil {
                  self.userModel = userData
              }
            
          }
          get {
              return userModel
          }
      }


      override init() {
          
      }
}
