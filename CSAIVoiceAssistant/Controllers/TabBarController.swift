//
//  TabBarController.swift
//  CSAIVoiceAssistant
//
//  Created by Ryan Elliott on 5/6/19.
//  Copyright © 2019 Cal Poly CSAI. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBar()
    }
    
    private func configureTabBar() {
        tabBar.isTranslucent = false
        
        let dcVC = DataCollectionViewController()
        let dataCollectionViewController = UINavigationController(rootViewController: dcVC)
        dataCollectionViewController.tabBarItem.image = UIImage(named: "mic")
        let dataVC = DataViewController()
        dataVC.dataCollectionDelegate = dcVC
        dcVC.dataDelegate = dataVC
        let dataViewController = UINavigationController(rootViewController: dataVC)
        dataViewController.tabBarItem.image = UIImage(named: "database")
        
        viewControllers = [dataCollectionViewController, dataViewController]
        
        // Center tab bar items without titles
        if let tabBarItems = tabBar.items {
            for tabItem in tabBarItems {
                tabItem.title = nil
                tabItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
            }
        }
    }
}
