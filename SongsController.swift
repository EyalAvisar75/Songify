import UIKit
import AVFoundation
var audioPlayer: AVAudioPlayer!

class SongsController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var songsTable: UITableView!
    @IBOutlet weak var musicButton: UIButton!
    
    var songs = [URL]()
    
    // MARK:- View methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        musicButton.isHidden = true
        audioPlayer = AVAudioPlayer()
        songs = getFilesFromDirectory()
    }
    
    func playSong(at index: Int) {
        musicButton.isHidden = false
        musicButton.setTitle("Pause", for: .normal)
        
        let url: URL? = songs[index]
        
        do {
            let isReachable = try url!.checkResourceIsReachable()
            print(isReachable)
            audioPlayer = try AVAudioPlayer(contentsOf: url!, fileTypeHint: AVFileType.mp3.rawValue)

            guard let player = audioPlayer else { return }

            player.prepareToPlay()
            player.play()
        } catch let error {
            print("printing error")
            print(error.localizedDescription)
        }

    }
    
    
    
    //MARK:- helper methods
    
    @IBAction func downloadFile(_ sender: Any) {
        if let audioUrl = URL(string: "https://file-examples-com.github.io/uploads/2017/11/file_example_MP3_700KB.mp3") {
            
            // then lets create your document folder url
            let baseURL = getDocumentDirectory()
            
            // lets create your destination file url
            let destinationUrl = baseURL.appendingPathComponent(audioUrl.lastPathComponent)
            print(destinationUrl)
            
            // to check if it exists before downloading it
            if FileManager.default.fileExists(atPath: destinationUrl.path) {
                print("The file already exists at path")
                
                // if the file doesn't exist
            } else {
                
                URLSession.shared.downloadTask(with: audioUrl, completionHandler: { (location, response, error) -> Void in
                    guard let location = location, error == nil else { return }
                    do {
                        // after downloading your file you need to move it to your destination url
                        try FileManager.default.moveItem(at: location, to: destinationUrl)
                        self.songs = self.getFilesFromDirectory()
                        
                        print("File moved to documents folder")
                        
                        DispatchQueue.main.async {
                            self.songsTable.reloadData()
                        }
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                }).resume()
            }
        }
        
    }
    
    func getDocumentDirectory() -> URL {
         return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    func getFilesFromDirectory() -> [URL] {
        var songs = [URL]()
        do {
            let documentsURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            songs = try FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options:  .skipsHiddenFiles)
            songs = songs.filter{ $0.pathExtension == "mp3" }
            print(songs)
        } catch {
            print(error)
        }
        
        return songs
    }
    
    
    
    @IBAction func musicButtonPressed(_ sender: UIButton) {
        
        if  audioPlayer.isPlaying{
            audioPlayer.pause()
            sender.setTitle("Play", for: .normal)
        }
        else{
            sender.setTitle("Pause", for: .normal)
            audioPlayer.play()
        }
    }
    
    //MARK:- Table delegate, datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath)
        
        let songTitle = songs[indexPath.row].lastPathComponent.description
        cell.textLabel?.text = songTitle
        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        playSong(at: indexPath.row)
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
