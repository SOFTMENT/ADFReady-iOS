//
//  ContentTableViewCell.swift
//  Royal Australian Navy
//
//  Created by Vijay Rathore on 29/10/23.
//

import UIKit

class RoyalContentTableViewCell : UITableViewCell {
    
    @IBOutlet weak var mView: UIView!
    @IBOutlet weak var mImage: UIImageView!
    @IBOutlet weak var mTitle: UILabel!
    
    @IBOutlet weak var pdfImage: UIImageView!
    @IBOutlet weak var videoStack: UIStackView!
    @IBOutlet weak var duration: UILabel!
    
    
    override class func awakeFromNib() {
        
    }
    
}
