//
//  ContentModel.swift
//  Adf Ready
//
//  Created by Vijay Rathore on 17/11/24.
//

import UIKit

class ContentModel : NSObject, Codable {
    var id : String?
    var title : String?
    var hyperLink : String?
    var hyperLinkId : String?
    var pdfLink : String?
    var type : String?
    var date : Date?
    var image : String?
    var orderIndex : Int?
    var videoCount : Int?
    var multiVideoModels : Array<MultiVideoModel>?
    
}
