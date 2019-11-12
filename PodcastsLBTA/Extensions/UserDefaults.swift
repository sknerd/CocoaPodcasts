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
    static let downloadedEpisodeKey = "downloadedEpisodeKey"
    
    func downloadEpisode(episode: Episode) {
        
        do {
            var episodes = downloadedEpisodes()
            if episodes.isEmpty {
                episodes.append(episode)
            } else {
                if !episodes.contains(where: { $0.title == episode.title && $0.author == episode.author}) {
                    episodes.insert(episode, at: 0)
                }
            }
            
            let data = try JSONEncoder().encode(episodes)
            UserDefaults.standard.set(data, forKey: UserDefaults.downloadedEpisodeKey)
        } catch let encodeErr {
            print("Failed to encode episode:", encodeErr)
        }
    }
    
    func downloadedEpisodes() -> [Episode] {
        guard let episodesData = UserDefaults.standard.data(forKey: UserDefaults.downloadedEpisodeKey) else { return [] }
        do {
            let episodes = try JSONDecoder().decode([Episode].self, from: episodesData)
            return episodes
        } catch let decodeErr {
            print("Failed to decode:", decodeErr)
        }
        return []
    }
    
    func deleteEpisode(episode: Episode) {
        let episodes = downloadedEpisodes()
        let filteredEpisodes = episodes.filter { (e) -> Bool in
            return e.title != episode.title && e.author != episode.author
        }
        do {
            let data = try JSONEncoder().encode(filteredEpisodes)
            UserDefaults.standard.set(data, forKey: UserDefaults.downloadedEpisodeKey)
        } catch let deleteErr {
            print("Failed to delete downloaded episode from UserDefaults:", deleteErr)
        }
    }
    
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


