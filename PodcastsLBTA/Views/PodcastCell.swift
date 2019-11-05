//
//  PodcastCell.swift
//  PodcastsLBTA
//
//  Created by renks on 01/11/2019.
//  Copyright © 2019 Renald Renks. All rights reserved.
//

import UIKit
import SDWebImage

class PodcastCell: UITableViewCell {
    
    @IBOutlet weak var podcastImageView: UIImageView! {
        didSet {
            podcastImageView.contentMode = .scaleToFill
            podcastImageView.layer.cornerRadius = 7
            podcastImageView.clipsToBounds = true
        }
    }
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var episodeCountLabel: UILabel!
    
    var podcast: Podcast! {
        didSet {
            trackNameLabel.text = podcast.trackName
            artistNameLabel.text = podcast.artistName
            episodeCountLabel.text = "\(podcast.trackCount ?? 0) Episodes"

            guard let url = URL(string: podcast.artworkUrl600 ?? "") else { return }
            
            //loading images without caching with tradiotional URLSession
            
//            URLSession.shared.dataTask(with: url) { (data, _, _) in
//                print("Finished downloading image data:", data)
//                guard let data = data else { return }
//                DispatchQueue.main.async {
//                    self.podcastImageView.image = UIImage(data: data)
//                }
//            }.resume()
    
            //loading and caching images using SDWebImage 
            podcastImageView.sd_setImage(with: url, completed: nil)
        }
    }
}
