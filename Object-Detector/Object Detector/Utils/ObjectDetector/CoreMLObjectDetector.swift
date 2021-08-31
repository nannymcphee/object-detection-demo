//
//  VisionObjectDetector.swift
//  Object Detector
//
//  Created by Duy Nguyen on 21/08/2021.
//

import Vision
import RxSwift

class CoreMLObjectDetector {
    // MARK: - Variables
    private let modelConfig = MLModelConfiguration()
    private var model: VNCoreMLModel
    
    // MARK: - Initializers
    init() {
        if let visionModel = try? VNCoreMLModel(for: YOLOv3Int8LUT(configuration: self.modelConfig).model) {
            self.model = visionModel
        } else {
            fatalError("Initialized visionModel failed")
        }
    }
    
    // MARK: - Public functions
    public func detectObjects(in cgImages: [CGImage]) -> Single<[DetectedObjectModel]> {
        let detectedObjectObservables = cgImages.map { detectObjects(in: $0) }
        return Single.zip(detectedObjectObservables)
            .map {
                $0.flatMap { $0.filter { $0.confidence > 0.3 } }
            }
            .map { [unowned self] in self.removingDuplicates($0) }
    }
    
    public func detectObjects(in cgImage: CGImage) -> Single<[DetectedObjectModel]> {
        return .create { [unowned self] single in
            let handler = VNImageRequestHandler(cgImage: cgImage)
            let request = VNCoreMLRequest(model: model, completionHandler: { request, error in
                if let error = error {
                    single(.failure(error))
                }
                
                if let result = request.results as? [VNRecognizedObjectObservation] {
                    let detectedObjects = result.map { DetectedObjectModel(object: $0) }
                    single(.success(detectedObjects))
                }
            })
            
            do {
                try handler.perform([request])
            } catch let error {
                single(.failure(error))
            }
            
            return Disposables.create()
        }
    }
    
    public func detectObjects(in pixelBuffer: CVPixelBuffer) -> Single<[DetectedObjectModel]> {
        return .create { [unowned self] single in
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer)
            let request = VNCoreMLRequest(model: model, completionHandler: { request, error in
                if let error = error {
                    single(.failure(error))
                }
                
                if let result = request.results as? [VNRecognizedObjectObservation] {
                    let detectedObjects = result.map { DetectedObjectModel(object: $0) }
                    single(.success(detectedObjects))
                }
            })
            request.imageCropAndScaleOption = .scaleFill
            
            do {
                try handler.perform([request])
            } catch let error {
                single(.failure(error))
            }
            
            return Disposables.create()
        }
    }
}

// MARK: - Private functions
private extension CoreMLObjectDetector {
    func initModel() {
        if let visionModel = try? VNCoreMLModel(for: YOLOv3Int8LUT(configuration: self.modelConfig).model) {
            self.model = visionModel
        } else {
            fatalError("Initialized visionModel failed")
        }
    }
    
    func removingDuplicates(_ data: [DetectedObjectModel]) -> [DetectedObjectModel] {
        var addedDict = [String: DetectedObjectModel]()
        
        return data.filter {
            return addedDict.updateValue($0, forKey: $0.label) == nil
        }
    }
}

extension VNRecognizedObjectObservation {
    var label: String {
        return (self.labels.first?.identifier).orEmpty
    }
}
