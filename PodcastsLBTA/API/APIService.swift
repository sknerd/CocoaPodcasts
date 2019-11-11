//
//  APIService.swift
//  PodcastsLBTA
//
//  Created by renks on 31/10/2019.
//  Copyright © 2019 Renald Renks. All rights reserved.
//

import Foundation
import Alamofire
import FeedKit

extension Notification.Name {
    
    static let downloadProgress = NSNotification.Name("downloadProgress")
    static let downloadComplete = NSNotification.Name("downloadComplete")
}

class APIService {
    
    typealias EpisodeDownloadCompleteTuple = (fileUrl: String, episodeTitle: String)
    
    let baseItunesSearchUrl = "https://itunes.apple.com/search"
    
    //singleton
    static let shared = APIService()
    
    func downloadEpisode(episode: Episode) {
        print("Downloading episode using Alamofire at stream url:", episode.streamUrl)
        
        let downloadRequest = DownloadRequest.suggestedDownloadDestination()
        
        AF.download(episode.streamUrl, to: downloadRequest).downloadProgress { (progress) in
            print(progress.fractionCompleted)
            
            //notify DownloadsController about my download progress
            
            NotificationCenter.default.post(name: .downloadProgress, object: nil, userInfo: ["title": episode.title, "progress": progress.fractionCompleted])
            
        }.response { (resp) in
            print(resp.fileURL?.absoluteString ?? "")
            
            let episodeDownloadComplete = EpisodeDownloadCompleteTuple(fileUrl: resp.fileURL?.absoluteString ?? "", episodeTitle: episode.title)
            
            NotificationCenter.default.post(name: .downloadComplete, object: episodeDownloadComplete, userInfo: nil)
            
            //update UserDefauls downloaded episodes with this temp file
            
            var downloadedEpisodes = UserDefaults.standard.downloadedEpisodes()
            guard let index = downloadedEpisodes.firstIndex(where: { $0.title == episode.title && $0.author == episode.author }) else { return }
            downloadedEpisodes[index].fileUrl = resp.fileURL?.absoluteString ?? ""
            
            do {
                let data = try JSONEncoder().encode(downloadedEpisodes)
                UserDefaults.standard.set(data, forKey: UserDefaults.downloadedEpisodeKey)
            } catch let err {
                print("Failed to encode downloaded episodes with file url update:", err)
            }
        }
    }
    
    func fetchEpisodes(feedUrl: String, completionHandler: @escaping ([Episode]) -> ()) {
        let secureFeedUrl = feedUrl.contains("https") ? feedUrl : feedUrl.replacingOccurrences(of: "http", with: "https")
        guard let url = URL(string: secureFeedUrl) else { return }
        
        DispatchQueue.global(qos: .background).async {
            let parser = FeedParser(URL: url)
            parser.parseAsync(queue: DispatchQueue.global(qos: .userInitiated)) { (result) in
                
                switch result {
                case .success(let feed):
                    
                    guard let episodes = feed.rssFeed?.toEpisodes() else { return }
                    completionHandler(episodes)
                    
                case .failure(let error):
                    print("Failed to parse feed:", error)
                }
            }
        }
    }
    
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
