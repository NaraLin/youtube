//
//  MainTableViewController.swift
//  youtube
//
//  Created by 林靖芳 on 2024/5/29.
//

import UIKit

class MainTableViewController: UITableViewController {
    @IBOutlet weak var channelIntroLabel: UILabel!
    @IBOutlet weak var videoCount: UILabel!
    @IBOutlet weak var subscriberCount: UILabel!
    @IBOutlet weak var channelNameLabel: UILabel!
    @IBOutlet weak var channelImageView: UIImageView!
    @IBOutlet weak var bannerImageView: UIImageView!
    
    var videoChannelInfo:[Items] = []
    var playlist:[PlaylistItems] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        channelImageView.layer.cornerRadius = channelImageView.bounds.width/2
        channelImageView.clipsToBounds = true
        bannerImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            bannerImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bannerImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bannerImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])
        fetchChannelInfo()
        fetchVideoInfo()
        
    }
    
    
    //數字的字串轉換成以萬為單位顯示
    func convertToTenThousands(from numberString: String) -> String? {
        
        // 將字符串轉換成 Double
        guard let number = Double(numberString) else {
            return nil
        }
        
        // 計算以萬為單位的數值
        let numberInTenThousands = number / 10000
        
        // 格式化輸出，如果小數點後是.00則不顯示
        let numberToString = String(format: "%.2f 萬", numberInTenThousands)
        if numberToString.hasSuffix(".00 萬"){
            return "\(Int(numberInTenThousands))萬"
        }else{
            return "\(numberToString)"
        }
    }
    //Date >> time ago 方式顯示
    func timeAgo(date:Date)->String?{
        
        //使用者目前的日曆
        let calendar = Calendar.current

        //以什麼樣的格式回傳兩個日期的差異(比較年/月/日)
        let components = calendar.dateComponents([.year,.month,.day], from: date, to: .now)
        
        if let years = components.year, years > 0{
            return "\(years)年前"
        }else if let months = components.month, months > 0{
            return "\(months)個月前"
        }else if let days = components.day, days > 0{
            return "\(days)天前"
        }else{
            return "今天"
        }
        
    }
        
      
    
    //抓取頻道資訊
    func fetchChannelInfo(){
        
        if let url = URL(string: "https://www.googleapis.com/youtube/v3/channels?part=snippet,contentDetails,statistics,topicDetails,status,contentOwnerDetails,brandingSettings&id=UCLkAepWjdylmXSltofFvsYQ&key=\(APIKey.default)"){
            
            URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                
                guard let self = self else { return }
                
                if let error {
                    print("\(error)")
                    return
                }
                
                guard let data else {
                    print("Error: no data")
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    let info = try decoder.decode(ChannelJson.self, from: data)
                    self.videoChannelInfo = info.items
                    DispatchQueue.main.async {
                        self.updateUI()
                    }
                } catch {
                    print("Error: decode data error")
                }
            }.resume()
        }
    }
    
    func updateUI(){
        guard let channelInfo = videoChannelInfo.first else {
            return
        }
        
        channelNameLabel.text = channelInfo.snippet.title
        channelNameLabel.font = UIFont.boldSystemFont(ofSize: 24)
        
        let subscriberDetailCount = channelInfo.statistics.subscriberCount
        if let formattedCount = convertToTenThousands(from: subscriberDetailCount) {
            subscriberCount.text = formattedCount + "位訂閱者"
        }
        
        videoCount.text = (channelInfo.statistics.videoCount) + "部影片"
        channelIntroLabel.text = channelInfo.snippet.description
        channelIntroLabel.numberOfLines = 0
        channelIntroLabel.font = UIFont.systemFont(ofSize: 16)
        channelIntroLabel.textColor = UIColor.gray
        
        loadImage(from: channelInfo.brandingSettings.image.bannerExternalUrl, into: bannerImageView)
        loadImage(from: channelInfo.snippet.thumbnails.defaultImg.url, into: channelImageView)
        }
    
    
    func loadImage(from url: URL, into imageView: UIImageView) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data{
                DispatchQueue.main.async {
                    imageView.image = UIImage(data: data)
                }
            }
        }.resume()
    }
    
    @IBSegueAction func showVideo(_ coder: NSCoder) -> WebViewController? {
        let controller = WebViewController(coder: coder)
        
        if let row = tableView.indexPathForSelectedRow?.row{
            controller?.video = playlist[row]
            return controller
        } else {
            return nil
        }
    }

    //抓取影片資訊
    func fetchVideoInfo(){
        if let url = URL(string: "https://www.googleapis.com/youtube/v3/playlistItems?key=\(APIKey.default)&part=snippet&playlistId=PL5hrGMysD_GuqSBxBtwuXRmyuvzeQyDs6&maxResults=50"){
            
            URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                guard let self = self else { return }
                if let data{
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    if let info = try? decoder.decode(playlistItem.self, from: data) {
                        self.playlist = info.items
                        DispatchQueue.main.async{
                            self.tableView.reloadData()
                        }
                    }
                } else if let error{
                    print("Error: fetch video info \(error.localizedDescription)")
                }
            }.resume()
            
        }
        
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return playlist.count
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(VideoTableViewCell.self)", for: indexPath) as! VideoTableViewCell
        cell.selectionStyle = .none
        let playListItem = playlist[indexPath.row]
        cell.configure(with: playListItem)
        loadImage(for: cell, at: indexPath, with: playlist[indexPath.row].snippet.thumbnails.high.url)
    
        return cell
    }
    
    func loadImage(for cell: VideoTableViewCell, at indexPath: IndexPath, with url: URL) {
        cell.videoImageView.image = nil
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                guard let currentIndexPath = self.tableView.indexPath(for: cell), currentIndexPath == indexPath else {
                    return
                }
                if let error {
                    print("Error: Loading image \(error.localizedDescription)")
                    return
                }
                if let data {
                    let image = UIImage(data: data)
                    cell.videoImageView.image = UIImage(data: data)
                    cell.videoImageView.layer.cornerRadius = 10
                }
            }
        }.resume()
        
    }
    
    
}

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


