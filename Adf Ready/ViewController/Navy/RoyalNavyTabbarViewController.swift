//
//  NavyTabbarViewController.swift
//  Royal Australian Navy Fitness
//
//  Created by Vijay Rathore on 10/01/24.
//

import UIKit
import Firebase

class RoyalNavyTabbarViewController : UITabBarController, UITabBarControllerDelegate {
  
    var tabBarItems = UITabBarItem()
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate  = self

        
        let selectedImage1 = UIImage(named: "boat-anchor")?.withRenderingMode(.alwaysOriginal)
        let deSelectedImage1 = UIImage(named: "boat-anchor-2")?.withRenderingMode(.alwaysOriginal)
        tabBarItems = self.tabBar.items![0]
        
        tabBarItems.image = deSelectedImage1
        tabBarItems.selectedImage = selectedImage1
        
        let selectedImage2 = UIImage(named: "navyclub")?.withRenderingMode(.alwaysOriginal)
        let deSelectedImage2 = UIImage(named: "navyclub10")?.withRenderingMode(.alwaysOriginal)
        tabBarItems = self.tabBar.items![1]
        tabBarItems.image = deSelectedImage2
        tabBarItems.selectedImage = selectedImage2
        
        
        let selectedImage3 = UIImage(named: "qr")?.withRenderingMode(.alwaysOriginal)
        let deSelectedImage3 = UIImage(named: "qr-2")?.withRenderingMode(.alwaysOriginal)
        tabBarItems = self.tabBar.items![2]
        tabBarItems.image = deSelectedImage3
        tabBarItems.selectedImage = selectedImage3
        
        
        
        let selectedImage4 = UIImage(named: "black-and-white-chat-bubbles")?.withRenderingMode(.alwaysOriginal)
        let deSelectedImage4 = UIImage(named: "black-and-white-chat-bubbles-2")?.withRenderingMode(.alwaysOriginal)
        tabBarItems = self.tabBar.items![3]
        tabBarItems.image = deSelectedImage4
        tabBarItems.selectedImage = selectedImage4
        
        let selectedImage5 = UIImage(named: "pin")?.withRenderingMode(.alwaysOriginal)
        let deSelectedImage5 = UIImage(named: "pin-2")?.withRenderingMode(.alwaysOriginal)
        tabBarItems = self.tabBar.items![4]
        tabBarItems.image = deSelectedImage5
        tabBarItems.selectedImage = selectedImage5
    
      
    
        
        selectedIndex = 0
        

    }
    
    func selectTabbarIndex(position : Int){
        selectedIndex = position
    }


}


