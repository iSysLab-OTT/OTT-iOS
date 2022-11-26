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
import SnapKit

class ViewController: RPBroadcastActivityViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let broadcastPicker = RPSystemBroadcastPickerView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        self.view.addSubview(broadcastPicker)
        broadcastPicker.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(50)
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(5)
        }
        broadcastPicker.preferredExtension = "com.chongin12.dev.ott.record"
        
        [netflixButton, wavveButton, disneyplusButton, tvingButton].forEach {
            $0?.setTitle("", for: .normal)
        }
        
        pointerTest()
    }
    
    private func pointerTest() {
        let count = 5
        let pointer = UnsafeMutablePointer<Int16>.allocate(capacity: count)
        defer { pointer.deallocate() }
        let dump: () -> () = {
          for i in 0..<count {
            print("\(pointer[i])")
          }
        }
        for i in 0..<count {
          pointer[i] = Int16(i+1234)
        }
        print("pointer pointee : \(pointer.pointee)")
        dump()
        
        let pointer2 = UnsafeMutablePointer<CChar>.allocate(capacity: count)
        defer { pointer2.deallocate() }
        let dump2: () -> () = {
          for i in 0..<count {
            print("\(pointer2[i])")
          }
        }
        for i in 0..<count {
            pointer2[i] = CChar("\((i*99)%10)")!
        }
        print("pointer2 pointee : \(pointer2.pointee)")
        dump2()
        
//        let a: Int32 = 1
//        let b: Int32 = 2
//        let res = addTwoIntegers(a, b)
//        print(res)
        

        let pointer123 = UnsafeMutablePointer<Int16>.allocate(capacity: 72608)
        
        let len: Int32 = 72608
        
        let pointer234 = UnsafeMutablePointer<CChar>.allocate(capacity: 1285)
        
        let ret = pcm_to_dna(pointer123, len, pointer234)
        print("ret : \(ret)")
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
