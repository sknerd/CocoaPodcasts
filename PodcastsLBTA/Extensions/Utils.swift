//
//  Utils.swift
//  PodcastsLBTA
//
//  Created by renks on 12/11/2019.
//  Copyright © 2019 Renald Renks. All rights reserved.
//

import UIKit

fileprivate var activityView : UIView?

extension UIViewController {
    
    func showSpinner() {
        activityView = UIView(frame: self.view.bounds)
//        activityView?.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.3)
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = activityView!.center
        activityIndicator.startAnimating()
        activityView?.addSubview(activityIndicator)
        self.view.addSubview(activityView!)
        
        Timer.scheduledTimer(withTimeInterval: 20, repeats: false) { (t) in
            self.removeSpinner()
        }
    }
    
    func removeSpinner() {
        activityView?.removeFromSuperview()
        activityView = nil
    }
    
}
