//
//  SampleHandler.swift
//  record
//
//  Created by 정종인 on 2022/07/19.
//

import ReplayKit
//import DNA

class SampleHandler: RPBroadcastSampleHandler {

    private var writer: BroadcastWriter?
    private let fileManager: FileManager = .default
    private let nodeURL: URL

    override init() {
        print("init, ")
        nodeURL = fileManager.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension(for: .mpeg4Movie)

        fileManager.removeFileIfExists(url: nodeURL)
        do {
            let url = (fileManager.containerURL(
                forSecurityApplicationGroupIdentifier: "group.chongin12.dev"
            )?.appendingPathComponent("Library/"))!
            try fileManager.removeItem(at: url)
        } catch { }

        super.init()
    }

    override func broadcastStarted(withSetupInfo setupInfo: [String : NSObject]?) {
        print("started")
        let screen: UIScreen = .main
        do {
            writer = try .init(
                outputURL: nodeURL,
                screenSize: screen.bounds.size,
                screenScale: screen.scale
            )
        } catch {
            assertionFailure(error.localizedDescription)
            finishBroadcastWithError(error)
            return
        }
        do {
            try writer?.start()
        } catch {
            finishBroadcastWithError(error)
        }
        print("started fin")
    }

    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        guard let writer = writer else {
            debugPrint("processSampleBuffer: Writer is nil")
            return
        }

        do {
            let captured = try writer.processSampleBuffer(sampleBuffer, with: sampleBufferType)
            debugPrint("processSampleBuffer captured", captured)
        } catch {
            debugPrint("processSampleBuffer error:", error.localizedDescription)
        }
    }

    override func broadcastPaused() {
        debugPrint("=== paused")
        writer?.pause()
    }

    override func broadcastResumed() {
        debugPrint("=== resumed")
        writer?.resume()
    }

    override func broadcastFinished() {
        print("broadcast finished")
        guard let writer = writer else {
            return
        }

        let outputURL: URL
        do {
            outputURL = try writer.finish()
        } catch {
            debugPrint("writer failure", error)
            return
        }

        guard let containerURL = fileManager.containerURL(
                    forSecurityApplicationGroupIdentifier: "group.chongin12.dev"
        )?.appendingPathComponent("Library/") else {
            fatalError("no container directory")
        }
        do {
            try fileManager.createDirectory(
                at: containerURL,
                withIntermediateDirectories: true,
                attributes: nil
            )
        } catch {
            debugPrint("error creating", containerURL, error)
        }

        let destination = containerURL.appendingPathComponent(outputURL.lastPathComponent)
        do {
            debugPrint("Moving", outputURL, "to:", destination)
            try self.fileManager.moveItem(
                at: outputURL,
                to: destination
            )
        } catch {
            debugPrint("ERROR", error)
        }

        debugPrint("FINISHED")
    }
}

extension FileManager {

    func removeFileIfExists(url: URL) {
        guard fileExists(atPath: url.path) else { return }
        do {
            try removeItem(at: url)
        } catch {
            print("error removing item \(url)", error)
        }
    }
}
