//
//  ContentTableViewCell.swift
//  Adf Ready
//
//  Created by Vijay Rathore on 17/11/24.
//

import UIKit

class ContentTableViewCell : UITableViewCell {
    
    @IBOutlet weak var mView: UIView!
    @IBOutlet weak var mImage: UIImageView!
    @IBOutlet weak var mTitle: UILabel!
    
    @IBOutlet weak var pdfImage: UIImageView!
    @IBOutlet weak var videoStack: UIStackView!
    @IBOutlet weak var duration: UILabel!
    
    
    override class func awakeFromNib() {
        
    }
    
}
