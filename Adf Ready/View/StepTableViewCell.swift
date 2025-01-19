//
//  StepTableViewCell.swift
//  Adf Ready
//
//  Created by Vijay Rathore on 19/11/24.
//

import UIKit

class StepTableViewCell: UITableViewCell {
   
    @IBOutlet weak var mView: RoundedView!
    
    @IBOutlet weak var stepsLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
}
