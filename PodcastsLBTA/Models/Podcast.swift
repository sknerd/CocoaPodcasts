//
//  Podcast.swift
//  PodcastsLBTA
//
//  Created by renks on 30/10/2019.
//  Copyright © 2019 Renald Renks. All rights reserved.
//

import Foundation

struct Podcast: Decodable {
    var trackName: String?
    var artistName: String?
    var artworkUrl600: String?
    var trackCount: Int?
    var feedUrl: String?
}
