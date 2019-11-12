//
//  EpisodesCell.swift
//  PodcastsLBTA
//
//  Created by renks on 02/11/2019.
//  Copyright © 2019 Renald Renks. All rights reserved.
//

import UIKit

class EpisodesCell: UITableViewCell {
    
    var episode: Episode! {
        didSet {
            titleLabel.text = episode.title
            descriptionLabel.text = episode.description
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy"
            pubDateLabel.text = dateFormatter.string(from: episode.pubDate)
            
            let url = URL(string: episode.imageUrl?.toSecureHTTPS() ?? "")
            episodeImageView.sd_setImage(with: url)
            
            let downloadedEpisodes = UserDefaults.standard.downloadedEpisodes()
            
            if downloadedEpisodes.isEmpty {
                downloadButton.isHidden = false
            } else if downloadedEpisodes.contains(where: { $0.title == episode.title && $0.author == episode.author}) {
                downloadButton.isHidden = true
            } else {
                downloadButton.isHidden = false
                
            }
        }
    }
    
    
    @IBOutlet weak var episodeImageView: UIImageView! {
        didSet {
            episodeImageView.layer.cornerRadius = 7
            episodeImageView.clipsToBounds = true
        }
    }
    @IBOutlet weak var pubDateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    
    @IBOutlet weak var downloadButton: UIButton!
    
    
    @IBAction func handleDownload(_ sender: Any) {
        
        UserDefaults.standard.downloadEpisode(episode: episode)
        APIService.shared.downloadEpisode(episode: episode)
        downloadButton.isHidden = true
        UIApplication.mainTabBarController()?.viewControllers?[2].tabBarItem.badgeValue = ""
        
    }
}
