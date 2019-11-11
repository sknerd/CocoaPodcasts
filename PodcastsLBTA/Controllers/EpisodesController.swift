//
//  EpisodesController.swift
//  PodcastsLBTA
//
//  Created by renks on 01/11/2019.
//  Copyright © 2019 Renald Renks. All rights reserved.
//

import UIKit
import FeedKit

class EpisodesController: UITableViewController {
    
    var podcast: Podcast? {
        didSet {
            navigationItem.title = podcast?.trackName
            
            fetchEpisodes()
        }
    }
    
    private func fetchEpisodes() {
        print("Looking for episodes at feed url:", podcast?.feedUrl ?? "")
        
        //implementing FeedKit for parsing RSS feed
        guard let feedUrl = podcast?.feedUrl else { return }
        
        APIService.shared.fetchEpisodes(feedUrl: feedUrl) { (episodes) in
            self.episodes = episodes
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private let cellId = "cellId"
    
    var episodes = [Episode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupNavigationBarButtons()
        
    }
    
    //MARK:- Setup Work
    
    fileprivate func setupNavigationBarButtons() {
        
        //check if we have already save this podcast as fav
        
        let savedPodcasts = UserDefaults.standard.savedPodcasts()
        let hasFavorited = savedPodcasts.firstIndex(where: { $0.trackName == self.podcast?.trackName && $0.artistName == self.podcast?.artistName }) != nil
        
        if hasFavorited {
            //setting up our heart icon
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "heart.fill"), style: .plain, target: nil, action: nil)
        } else {
            navigationItem.rightBarButtonItems = [
                UIBarButtonItem(title: "Favorite", style: .plain, target: self, action: #selector(handleSaveFavorite)),
//                UIBarButtonItem(title: "Fetch", style: .plain, target: self, action: #selector(handleFetchSavedPodcasts))
            ]
        }
    }
    
    @objc fileprivate func handleSaveFavorite() {
        print("Saving into user defaults")
        
        guard let podcast = self.podcast else { return }
        var listOfPodcasts = UserDefaults.standard.savedPodcasts()
        
        listOfPodcasts.append(podcast)
        
        //1. transform podcast into Data
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: listOfPodcasts, requiringSecureCoding: false)
            UserDefaults.standard.set(data, forKey: UserDefaults.favoritedPodcastKey)
            UserDefaults.standard.synchronize()
            showBadgeHighlight()
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "heart.fill"), style: .plain, target: nil, action: nil)
        } catch let err {
            print("Failed to convert into Data:", err.localizedDescription)
        }
    }
    
    fileprivate func showBadgeHighlight() {
        UIApplication.mainTabBarController()?.viewControllers?[1].tabBarItem.badgeValue = ""
    }
    
    @objc fileprivate func handleFetchSavedPodcasts() {
        print("Handle fetching saved podcast from user defaults")
        
        //how to retrieve our Podcast object from User Defaults
        
        guard let data = UserDefaults.standard.data(forKey: UserDefaults.favoritedPodcastKey) else { return }
        
        do {
            let savedPodcasts = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [Podcast]
            
            savedPodcasts?.forEach({ (podcast) in
                print(podcast.trackName ?? "")
            })
        } catch let err {
            print("Failed to transform from data", err)
        }
    }
    
    fileprivate func setupTableView() {
        let nib = UINib(nibName: "EpisodesCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
        tableView.tableFooterView = UIView()
    }
    
    //MARK:- UITableView
        
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let contextItem = UIContextualAction(style: .normal, title: "Download") {  (contextualAction, view, boolValue) in
            print("Downloading episode into UserDefaults...")
            
            let episode = self.episodes[indexPath.row]
            
            UserDefaults.standard.downloadEpisode(episode: episode)
            self.tableView.reloadData()
            
            //download episode using Alamofire
            APIService.shared.downloadEpisode(episode: episode)
        }
        contextItem.backgroundColor = .purple
        let swipeActions = UISwipeActionsConfiguration(actions: [contextItem])

        return swipeActions
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let activityIndicatorView = UIActivityIndicatorView(style: .large)
        activityIndicatorView.color = .darkGray
        activityIndicatorView.startAnimating()
        return activityIndicatorView
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return episodes.isEmpty ? 200 : 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episode = self.episodes[indexPath.row]
        let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController
        mainTabBarController?.maximizePlayerDetails(episode: episode)
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! EpisodesCell
        let episode = self.episodes[indexPath.row]
        cell.episode = episode
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 134
    }
    
}

