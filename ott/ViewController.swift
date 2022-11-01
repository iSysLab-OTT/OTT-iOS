//
//  ViewController.swift
//  ott
//
//  Created by 정종인 on 2022/07/19.
//

import UIKit
import AVFoundation
import AVKit
import ReplayKit

class ViewController: RPBroadcastActivityViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let broadcastPicker = RPSystemBroadcastPickerView(frame: CGRect(x: 100, y: 200, width: 50, height: 50))
        broadcastPicker.preferredExtension = "com.chongin12.dev.ott.record"
        
        self.view.addSubview(broadcastPicker)
        
        [netflixButton, wavveButton, disneyplusButton, tvingButton].forEach {
            $0?.setTitle("", for: .normal)
        }
        
    }
    
    
    @IBOutlet weak var netflixButton: UIButton!
    @IBOutlet weak var wavveButton: UIButton!
    @IBOutlet weak var disneyplusButton: UIButton!
    @IBOutlet weak var tvingButton: UIButton!
    private func launchOTT(with index: Int) {
        let url = ottURL[index]
        let linkURL = NSURL(string: url)
        
        if (UIApplication.shared.canOpenURL(linkURL! as URL)) {
            
            UIApplication.shared.open(linkURL! as URL)
        }
        else {
            print("Not installed.")
        }
    }
    @IBAction func netflixButtonDidTap(_ sender: Any) {
        launchOTT(with: 0)
    }
    @IBAction func wavveButtonDidTap(_ sender: Any) {
        launchOTT(with: 1)
    }
    @IBAction func disneyplusButtonDidTap(_ sender: Any) {
        launchOTT(with: 2)
    }
    @IBAction func tvingButtonDidTap(_ sender: Any) {
        launchOTT(with: 3)
    }
    
    let pickerData = ["Netflix", "Wavve", "Disney+", "Tving"]
    let ottURL = ["nflx", "tidcaptvpooq", "disneyplus", "tvingapp"].map { $0 + "://" }
    let assetName = ["netflix", "wavve", "disneyplus", "tving"]
    @IBAction func onTap(_ sender: UIButton) {
        read()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    private func read() {
        print("read")
        let fileManager = FileManager.default
        var mediaURLs: [URL] = []
        if let container = fileManager
            .containerURL(
                forSecurityApplicationGroupIdentifier: "group.chongin12.dev"
            )?.appendingPathComponent("Library/") {
            
            let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            do {
                let contents = try fileManager.contentsOfDirectory(atPath: container.path)
                print("contents : \(contents)")
                for path in contents {
                    if path.elementsEqual("Caches") {
                        continue
                    }
                    if !path.hasSuffix(".mp4") {
                        continue
                    }
//                    guard !path.hasSuffix(".plist") else {
//                        print("file at path \(path) is plist, exiting")
//                        return
//                    }
                    let fileURL = container.appendingPathComponent(path)
                    var isDirectory: ObjCBool = false
                    guard fileManager.fileExists(atPath: fileURL.path, isDirectory: &isDirectory) else {
                        return
                    }
                    guard !isDirectory.boolValue else {
                        return
                    }
                    let destinationURL = documentsDirectory.appendingPathComponent(path)
                    do {
                        try fileManager.moveItem(at: fileURL, to: destinationURL)
                        print("Successfully moved \(fileURL)", "to: ", destinationURL)
                    } catch {
                        print("error moving \(fileURL) to \(destinationURL)", error)
                    }
                    mediaURLs.append(destinationURL)
                    print("mediaURLs : \(mediaURLs)")
                }
            } catch {
                print("contents, \(error)")
            }
        } else {
            print("if let fail")
        }
        
        mediaURLs.last.map {
            print("mediaURLs.last.map")
            let asset: AVURLAsset = .init(url: $0)
            let item: AVPlayerItem = .init(asset: asset)
            
            let movie: AVMutableMovie = .init(url: $0)
            for track in movie.tracks {
                print("track", track)
            }
            
            let player: AVPlayer = .init(playerItem: item)
            let playerViewController: AVPlayerViewController = .init()
            playerViewController.player = player
            playerViewController.modalPresentationStyle = .fullScreen
            self.present(playerViewController, animated: true, completion: { [player = playerViewController.player] in
                player?.play()
            })
        }
    }
}
