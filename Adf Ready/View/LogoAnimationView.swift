//
//  LogoAnimationView.swift
//  Royal Australian Navy
//
//  Created by Vijay Rathore on 15/10/23.
//

import UIKit
import SwiftyGif

class LogoAnimationView: UIView {
   var logoGifImageView: UIImageView!
   
  
    
    func load(gifName : String) {
        
        logoGifImageView = {
            guard let gifImage = try? UIImage(gifName: gifName) else {
                return UIImageView()
            }
            return UIImageView(gifImage: gifImage, loopCount : 1)
        }()
        
        backgroundColor = UIColor(white: 255.0 / 255.0, alpha: 1)
        addSubview(logoGifImageView)
        logoGifImageView.pinEdgesToSuperView()
      
    }
}
