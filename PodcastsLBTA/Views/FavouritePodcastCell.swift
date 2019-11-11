//
//  FavouritePodcastCell.swift
//  PodcastsLBTA
//
//  Created by renks on 08/11/2019.
//  Copyright © 2019 Renald Renks. All rights reserved.
//

import UIKit

class FavouritePodcastCell: UICollectionViewCell {
    
    var podcast: Podcast! {
        didSet {
            nameLabel.text = podcast.trackName
            artistNameLabel.text = podcast.artistName
            
            let url = URL(string: podcast.artworkUrl600 ?? "")
            imageView.sd_setImage(with: url)
            imageView.layer.cornerRadius = 7
            imageView.clipsToBounds = true
        }
    }
    
    let imageView = UIImageView(image: UIImage(systemName: "play.rectangle.fill"))
    let nameLabel = UILabel()
    let artistNameLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
        stylizeUI()
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func stylizeUI() {
        nameLabel.text = "Podcast Name"
        nameLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        artistNameLabel.text = "Artist Name"
        artistNameLabel.font = UIFont.systemFont(ofSize: 14)
        artistNameLabel.textColor = .lightGray
    }
    
    fileprivate func setupViews() {
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .brown
        
        let stackView = UIStackView(arrangedSubviews: [imageView, nameLabel, artistNameLabel])
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
}
