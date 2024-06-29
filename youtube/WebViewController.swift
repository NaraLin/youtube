//
//  WebViewController.swift
//  youtube
//
//  Created by 林靖芳 on 2024/5/30.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    var video:PlaylistItems!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //youtube網址：https://www.youtube.com/watch?v= + video ID
        let videoID = video.snippet.resourceId.videoId
        if let url = URL(string: "https://www.youtube.com/watch?v=\(videoID)"){
            let request = URLRequest(url: url)
            webView.load(request)
        }

        // Do any additional setup after loading the view.
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
