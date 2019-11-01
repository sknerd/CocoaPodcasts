//
//  EpisodesController.swift
//  PodcastsLBTA
//
//  Created by renks on 01/11/2019.
//  Copyright © 2019 Renald Renks. All rights reserved.
//

import UIKit

class EpisodesController: UITableViewController {
    
    var podcast: Podcast? {
        didSet {
            navigationItem.title = podcast?.trackName
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        navigationItem.title = "Episodes"
    }
}
 
