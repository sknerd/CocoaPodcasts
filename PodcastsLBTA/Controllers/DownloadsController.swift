//
//  DownloadsController.swift
//  PodcastsLBTA
//
//  Created by renks on 11/11/2019.
//  Copyright © 2019 Renald Renks. All rights reserved.
//

import UIKit

class DownloadsController: UITableViewController {
    
    fileprivate let cellId = "cellId"
    
    var episodes = UserDefaults.standard.downloadedEpisodes()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = .white
        
        setupTableView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        episodes = UserDefaults.standard.downloadedEpisodes()
        tableView.reloadData()
    }
    
    fileprivate func setupTableView() {
        
        let nib = UINib(nibName: "EpisodesCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
    }
    
    //MARK:- UITableView
    
    
    //TODO: Change downloading action from swipe to button
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
         let contextItem = UIContextualAction(style: .destructive, title: "Delete") {  (contextualAction, view, boolValue) in
             print("Deleting episode frome UserDefaults...")
            let episode = self.episodes[indexPath.row]
            
            UserDefaults.standard.deleteEpisode(episode: episode)
            self.episodes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
         }
         let swipeActions = UISwipeActionsConfiguration(actions: [contextItem])

         return swipeActions
     }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! EpisodesCell
        
        cell.episode = self.episodes[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 132
    }
    
}

