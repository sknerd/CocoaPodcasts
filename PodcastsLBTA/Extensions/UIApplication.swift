//
//  UIApplication.swift
//  PodcastsLBTA
//
//  Created by renks on 05/11/2019.
//  Copyright © 2019 Renald Renks. All rights reserved.
//

import UIKit

extension UIApplication {
    static func mainTabBarController() -> MainTabBarController? {
        
        return shared.keyWindow?.rootViewController as? MainTabBarController
    }
}
