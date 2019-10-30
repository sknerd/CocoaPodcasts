//
//  MainTabBarController.swift
//  PodcastsLBTA
//
//  Created by renks on 30/10/2019.
//  Copyright © 2019 Renald Renks. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UINavigationBar.appearance().prefersLargeTitles = true
        
        tabBar.tintColor = .purple
        
        setupViewControllers()
    }
    
    //MARK: - Setup Functions
    
    func setupViewControllers() {
        viewControllers = [
            generateNavigationController(with: PodcastsSearchController(), title: "Search", image: #imageLiteral(resourceName: "search")),
            generateNavigationController(with: ViewController(), title: "Favourites", image: #imageLiteral(resourceName: "favourites")),
            generateNavigationController(with: ViewController(), title: "Downloads", image: #imageLiteral(resourceName: "downloads"))
        ]
    }
    
    //MARK:- Helper Functions
    
    private func generateNavigationController(with rootViewController: UIViewController, title: String, image: UIImage) -> UIViewController {
        let navController = UINavigationController(rootViewController: rootViewController)
        rootViewController.navigationItem.title = title
        navController.tabBarItem.title = title
        navController.tabBarItem.image = image
        return navController
    }
}
