//
//  VideoProcessor.swift
//  Object Detector
//
//  Created by Duy Nguyen on 21/08/2021.
//

import AVFoundation
import RxSwift

class VideoProcessor {
    private var asset: AVAsset
    private var generator: AVAssetImageGenerator!
    private var duration: TimeInterval {
        return CMTimeGetSeconds(asset.duration)
    }
    private var timeArr: [Float64] {
        return Array(0..<Int(duration)).map { Float64($0) }
    }
    
    public init(url: URL) {
        self.asset = AVAsset(url: url)
        self.initImageGenerator()
    }
    
    public func getAllFramesFromVideo() -> Single<[CGImage]> {
        let allFrameSingles = timeArr.map { getCGImage(from: $0) }
        return Single.zip(allFrameSingles)
    }
    
    public func updateVideoURL(_ url: URL) {
        self.asset = AVAsset(url: url)
        self.initImageGenerator()
    }
}

private extension VideoProcessor {
    func getCGImage(from time: Float64) -> Single<CGImage> {
        return .create { [unowned self] single in
            let time = CMTimeMakeWithSeconds(time, preferredTimescale: 600)
            let cgImage: CGImage
            do {
                try cgImage = self.generator.copyCGImage(at: time, actualTime: nil)
                single(.success(cgImage))
            } catch let error {
                single(.failure(error))
            }
            return Disposables.create()
        }
    }
    
    func initImageGenerator() {
        self.generator = AVAssetImageGenerator(asset: asset)
        self.generator.appliesPreferredTrackTransform = true
    }
}
