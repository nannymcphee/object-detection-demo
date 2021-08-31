//
//  DNObjectDetector.swift
//  Object Detector
//
//  Created by Duy Nguyen on 21/08/2021.
//

import AVFoundation
import RxSwift
import MLKitVision
import MLKitObjectDetection

enum ObjectDetectorType {
    case singleImage
    case liveCamera
}

class DNObjectDetector {
    private var objectDetector: ObjectDetector
    private var detectorType: ObjectDetectorType
    
    init(detectorType: ObjectDetectorType) {
        self.detectorType = detectorType
        let options = ObjectDetectorOptions()
        switch detectorType {
        case .liveCamera:
            options.detectorMode = .stream
            options.shouldEnableClassification = true
        case .singleImage:
            options.detectorMode = .singleImage
            options.shouldEnableClassification = true
            options.shouldEnableMultipleObjects = true
        }
        self.objectDetector = ObjectDetector.objectDetector(options: options)
    }
    
    public func detectObjects(in images: [CGImage]) -> Single<[DetectedObjectModel]> {
        let detectedObjectSingles = images.map { detectObjects(in: $0) }
        return Single.zip(detectedObjectSingles)
            .map {  $0.flatMap { $0.filter { $0.confidence > 0 } } }
    }
    
    public func detectObjects(in image: CGImage) -> Single<[DetectedObjectModel]> {
        return .create { [unowned self] single in
            let uiImage = UIImage(cgImage: image)
            let visionImage = VisionImage(image: uiImage)
            visionImage.orientation = uiImage.imageOrientation
            
            self.objectDetector.process(visionImage, completion: { detectObjects, error in
                if let error = error {
                    single(.failure(error))
                }
                
                guard let detectedObjects = detectObjects, !detectedObjects.isEmpty else {
                    single(.success([]))
                    return
                }
                
                var models = detectedObjects.map { DetectedObjectModel(object: $0) }
                models = self.removingDuplicates(models)
                
                single(.success(models))
            })
            
            return Disposables.create()
        }
    }
    
    public func detectObjects(in pixelBuffer: CVPixelBuffer) -> Single<[DetectedObjectModel]> {
        return .create { [unowned self] single in
            guard let sampleBuffer = self.getCMSampleBuffer(from: pixelBuffer) else { return Disposables.create() }
            let image = VisionImage(buffer: sampleBuffer)
            image.orientation = self.imageOrientation(deviceOrientation: UIDevice.current.orientation, cameraPosition: .back)
            
            self.objectDetector.process(image, completion: { detectObjects, error in
                if let error = error {
                    single(.failure(error))
                }
                
                guard let detectedObjects = detectObjects, !detectedObjects.isEmpty else {
                    single(.success([]))
                    return
                }
                
                var models = detectedObjects.map { DetectedObjectModel(object: $0) }
                models = self.removingDuplicates(models)
                
                single(.success(models))
            })
            
            return Disposables.create()
        }
    }
}

private extension DNObjectDetector {
    func removingDuplicates(_ data: [DetectedObjectModel]) -> [DetectedObjectModel] {
        var addedDict = [String: DetectedObjectModel]()
        
        return data.filter {
            return addedDict.updateValue($0, forKey: $0.label) == nil
        }
    }
    
    func imageOrientation(deviceOrientation: UIDeviceOrientation,
                          cameraPosition: AVCaptureDevice.Position) -> UIImage.Orientation {
        switch deviceOrientation {
        case .portrait:
            return cameraPosition == .front ? .leftMirrored : .right
        case .landscapeLeft:
            return cameraPosition == .front ? .downMirrored : .up
        case .portraitUpsideDown:
            return cameraPosition == .front ? .rightMirrored : .left
        case .landscapeRight:
            return cameraPosition == .front ? .upMirrored : .down
        case .faceDown, .faceUp, .unknown:
            return .up
        @unknown default:
            fatalError("Unknown device orientation")
        }
    }
    
    func getCMSampleBuffer(from buffer: CVPixelBuffer?) -> CMSampleBuffer? {
        var pixelBuffer = buffer
        CVPixelBufferCreate(kCFAllocatorDefault, 100, 100, kCVPixelFormatType_32BGRA, nil, &pixelBuffer)
        
        guard let pixelBuffer = pixelBuffer else { return nil }
        
        var info = CMSampleTimingInfo()
        info.presentationTimeStamp = CMTime.zero
        info.duration = CMTime.invalid
        info.decodeTimeStamp = CMTime.invalid
        
        var formatDesc: CMFormatDescription?
        CMVideoFormatDescriptionCreateForImageBuffer(allocator: kCFAllocatorDefault,
                                                     imageBuffer: pixelBuffer,
                                                     formatDescriptionOut: &formatDesc)
        
        var sampleBuffer: CMSampleBuffer?
        
        CMSampleBufferCreateReadyWithImageBuffer(allocator: kCFAllocatorDefault,
                                                 imageBuffer: pixelBuffer,
                                                 formatDescription: formatDesc!,
                                                 sampleTiming: &info,
                                                 sampleBufferOut: &sampleBuffer)
        
        return sampleBuffer
    }
}

extension Object {
    var label: String {
        return (labels.first?.text).orEmpty
    }
}
