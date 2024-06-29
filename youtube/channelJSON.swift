//
//  channelJSON.swift
//  youtube
//
//  Created by 林靖芳 on 2024/5/28.
//

import Foundation

struct ChannelJson:Decodable{
    let items:[Items]
}

struct Items:Decodable{
    let snippet:Snippet
    let statistics:Statistics
    let brandingSettings:BrandingSettings
}

struct Snippet:Decodable{
    let title:String //頻道名稱
    let description:String //頻道簡介
    let publishedAt:String //頻道創立時間
    let thumbnails:Thumbnails
    
}

struct Thumbnails:Decodable{
    let defaultImg:Default
    
    enum CodingKeys: String, CodingKey {
            case defaultImg = "default"
    }
    
}


struct Default:Decodable{
    let url:URL //頻道頭像
}

struct Statistics:Decodable{
    let viewCount:String
    let subscriberCount:String
    let videoCount:String
}

struct BrandingSettings:Decodable{
    let image:Image
}

struct Image:Decodable{
    let bannerExternalUrl:URL //banner圖片
}
