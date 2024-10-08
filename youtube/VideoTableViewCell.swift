//
//  VideoTableViewCell.swift
//  youtube
//
//  Created by 林靖芳 on 2024/5/29.
//

import UIKit

class VideoTableViewCell: UITableViewCell {

    @IBOutlet weak var publishedDateLabel: UILabel!
    @IBOutlet weak var channelNameLabel: UILabel!
    @IBOutlet weak var videoNameLabel: UILabel!
    @IBOutlet weak var videoImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with playlistItem: PlaylistItems) {
        channelNameLabel.text = playlistItem.snippet.channelTitle
        let isoDateString = playlistItem.snippet.publishedAt
        let result = MainTableViewController().timeAgo(date: isoDateString)
        publishedDateLabel.text = result
        videoNameLabel.text = playlistItem.snippet.title
        videoNameLabel.numberOfLines = 3
    }

}
