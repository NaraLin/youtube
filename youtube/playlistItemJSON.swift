//
//  playlistItemJSON.swift
//  youtube
//
//  Created by 林靖芳 on 2024/5/29.
//

import Foundation

struct playlistItem:Codable{
    let items:[PlaylistItems]
}
struct PlaylistItems:Codable{
    let snippet:PlaylistSnippet
}

struct PlaylistSnippet:Codable{
    let publishedAt:Date //發布日期
    let title:String //影片名稱
    let thumbnails:PlaylistThumbnails
    let channelTitle:String //頻道名稱
    let resourceId:ResourceID
}

struct PlaylistThumbnails:Codable{
    let high:High }

struct High:Codable{
    let url:URL //影片縮圖
    let width:Int
    let height:Int
}

struct ResourceID:Codable{
    var videoId:String //youtube網址：https://www.youtube.com/watch?v= + video ID
}
