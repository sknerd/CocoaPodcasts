//
//  PodcastSearchController.swift
//  PodcastsLBTA
//
//  Created by renks on 30/10/2019.
//  Copyright © 2019 Renald Renks. All rights reserved.
//

import UIKit

class PodcastsSearchController: UITableViewController, UISearchBarDelegate {
    
    let podcasts = [
        Podcast(name: "Kultura @ First Floor", artistName: "Renks"),
        Podcast(name: "Razdolbas", artistName: "Solid Angle")
    ]
    
    let cellId = "cellId"
    
    // let's implement UISearchController
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchBar()
        setupTableView()
        
    }
    
    //MARK:- Setup Work
    
    private func setupSearchBar() {
        navigationItem.searchController = searchController
        searchController.searchBar.delegate = self
    }
    
    private func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        //later implement Alamofire to search iTunes API
    }
    
    //MARK:- UITableView
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        podcasts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        let podcast = self.podcasts[indexPath.row]
        cell.textLabel?.text = "\(podcast.name)\n\(podcast.artistName)"
        cell.textLabel?.numberOfLines = 0
        cell.imageView?.image = #imageLiteral(resourceName: "432193022_456239651")
        
        return cell
    }
}
