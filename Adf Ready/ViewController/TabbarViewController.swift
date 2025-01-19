//
//  TabbarViewController.swift
//  Adf Ready
//
//  Created by Vijay Rathore on 16/11/24.
//


// Copyright © 2023 SOFTMENT. All rights reserved.

import Firebase
import UIKit

class TabbarViewController: UIViewController {
    // Outlets for tab bar buttons and images
    @IBOutlet var pageView: UIView!
    @IBOutlet weak var workoutImage: UIImageView!
  
    
  
    @IBOutlet weak var infoImage: UIImageView!
    
    @IBOutlet weak var playImage: UIImageView!
    @IBOutlet weak var pfaImage: UIImageView!
    
    @IBOutlet weak var profileImage: UIImageView!
    // Page view controller for managing child view controllers
    var pageViewController: UIPageViewController!

    // Lazy loading of view controllers
    lazy var viewControllers: [UIViewController] = {
        let infoVC = UIStoryboard.load("informationVC") as! InformationViewController
        let workoutVC = UIStoryboard.load("workoutVC") as! WorkoutViewController
        let PFAVC = UIStoryboard.load("pfaVC") as! PFATestingViewController
        let theReadyVC = UIStoryboard.load("readyVC") as! TheReadyHubViewController
       
        let profileVC = UIStoryboard.load("profileVC") as! ProfileViewController
        

        return [infoVC, workoutVC, PFAVC, theReadyVC, profileVC]
    }()

    override var prefersStatusBarHidden: Bool {
        true
    }
   

    override func viewDidLoad() {
        super.viewDidLoad()
        
      
        FirebaseStoreManager.messaging.subscribe(toTopic: "all")

        // Check if the user is authenticated
//        guard FirebaseStoreManager.auth.currentUser != nil else {
//            DispatchQueue.main.async {
//                self.logout()
//            }
//            return
//        }
//        
       

        // Initialize and configure the page view controller
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        pageViewController.setViewControllers([viewControllers[0]], direction: .forward, animated: true)
        pageView.addSubview(pageViewController.view)
        pageViewController.view.frame = pageView.frame
        pageViewController.didMove(toParent: self)

        // Set up gesture recognizers for tab bar buttons
        setupGestureRecognizers()

//        // Handle initial selected tab based on Constants.selectedTabBarPosition
//        switch Constants.selectedTabBarPosition {
//        case 0:
//            homeBtnClicked()
//        case 1:
//            searchBtnClicked()
//        case 3:
//            cameraBtnClicked()
//        case 5:
//            notificationBtnClicked()
//        case 6:
//            userBtnClicked()
//        default:
//            homeBtnClicked()
//        }
    }
    




    // Sets up gesture recognizers for tab bar buttons
    private func setupGestureRecognizers() {
        let buttons = [infoImage, workoutImage, pfaImage, playImage, profileImage]
        let selectors: [Selector] = [
            #selector(infolicked),
            #selector(workoutClicked),
            #selector(pfaClicked),
            #selector(theReadyClicked),
          
            #selector(profileClicked),
          
        ]

        for (button, selector) in zip(buttons, selectors) {
            button?.isUserInteractionEnabled = true
            button?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: selector))
        }
    }

    @objc func infolicked() {
        switchToViewController(at: 0)
    }

    @objc func workoutClicked() {
        switchToViewController(at: 1)
    }

    @objc func pfaClicked() {
      
            switchToViewController(at: 2)
        
    }

    @objc func theReadyClicked() {
      
            switchToViewController(at: 3)
        
    }

   
    @objc func profileClicked() {
       
           switchToViewController(at: 4)
      
    }

    

    

    // Helper function to switch view controllers
    private func switchToViewController(at index: Int) {
     
        switch index {
        case 0:
           
            pageViewController.setViewControllers([viewControllers[0]], direction: .reverse, animated: true)
        case 1:
        
            if  let workoutVC = viewControllers[1] as? WorkoutViewController {
               
                pageViewController.setViewControllers([workoutVC], direction: Constants.selectedTabBarPosition > 1 ? .reverse : .forward, animated: true)
            } else {
                pageViewController.setViewControllers([viewControllers[1]], direction: Constants.selectedTabBarPosition > 1 ? .reverse : .forward, animated: true)
            }
        case 2:
          
            pageViewController.setViewControllers([viewControllers[2]], direction: Constants.selectedTabBarPosition > 2 ? .reverse : .forward, animated: true)
        case 3:
          
            pageViewController.setViewControllers([viewControllers[3]], direction: Constants.selectedTabBarPosition > 3 ? .reverse : .forward, animated: true)
       
        case 4:
          
           
            pageViewController.setViewControllers([viewControllers[4]], direction: .forward, animated: true)
       
          
        default:
            break
        }
        Constants.selectedTabBarPosition = index
    }
}
