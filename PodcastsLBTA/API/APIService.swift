//
//  APIService.swift
//  PodcastsLBTA
//
//  Created by renks on 31/10/2019.
//  Copyright © 2019 Renald Renks. All rights reserved.
//

import Foundation
import Alamofire


class APIService {
    
    let baseItunesSearchUrl = "https://itunes.apple.com/search"

    //singleton
    static let shared = APIService()
    
    func fetchPodcast(searchText: String, completionHandler: @escaping ([Podcast]) -> ()) {
        print("Searching for podcasts...")
        
        let parameters = ["term": searchText, "media": "podcast"]
        
        AF.request(baseItunesSearchUrl, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseData { (responseData) in
            
            if let err = responseData.error {
                print("Failed to connect yahoo", err)
                return
            }
            
            guard let data = responseData.data else { return }
            do {

                let searchResult = try JSONDecoder().decode(SearchResults.self, from: data)
                
                completionHandler(searchResult.results)
                
            } catch let decodeErr {
                print("Failed to decode: ", decodeErr)
            }
        }
    }
    
    struct SearchResults: Decodable {
        let resultCount: Int
        let results: [Podcast]
    }
}
