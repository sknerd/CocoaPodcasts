//
//  UserDefaults.swift
//  PodcastsLBTA
//
//  Created by renks on 09/11/2019.
//  Copyright © 2019 Renald Renks. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    static let favoritedPodcastKey = "favoritedPodcastKey"
    
    func savedPodcasts() -> [Podcast] {
        
        var savedPodcastsList = [Podcast]()
        
        guard let savedPodcastData = UserDefaults.standard.data(forKey: UserDefaults.favoritedPodcastKey) else { return [] }
        do {
            guard let savedPodcasts = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedPodcastData) as? [Podcast] else { return [] }
            savedPodcastsList = savedPodcasts
        } catch let err {
            print("Failed to fetch saved podcasts:", err.localizedDescription)
        }
        return savedPodcastsList
    }
    
    
    func deletePodcast(podcast: Podcast) {
        let podcasts = savedPodcasts()
        let filteredPodcasts = podcasts.filter { (p) -> Bool in
            return p.trackName != podcast.trackName && p.artistName != podcast.artistName
        }
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: filteredPodcasts, requiringSecureCoding: false)
            UserDefaults.standard.set(data, forKey: UserDefaults.favoritedPodcastKey)
        } catch let err {
            print(err.localizedDescription)
        }
    }
}


