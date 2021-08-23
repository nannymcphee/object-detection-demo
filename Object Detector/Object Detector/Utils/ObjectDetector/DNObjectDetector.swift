//
//  DNObjectDetector.swift
//  Object Detector
//
//  Created by Duy Nguyen on 21/08/2021.
//

import RxSwift
import FirebaseMLVision
import FirebaseMLVisionObjectDetection

class DNObjectDetector {
    private var visionObjectDetector: VisionObjectDetector
    
    init(visionObjectDetector: VisionObjectDetector) {
        self.visionObjectDetector = visionObjectDetector
    }
    
    public func detectObjects(in images: [UIImage]) -> Single<[VisionObject]> {
        let detectedObjectSingles = images.map { detectObjects(in: $0) }
        return Single.zip(detectedObjectSingles)
            .map {  $0.flatMap { $0.filter { Double(truncating: ($0.confidence ?? 0)) > 0 } } }
    }
    
    public func detectObjects(in image: UIImage) -> Single<[VisionObject]> {
        return .create { [unowned self] single in
            let visionImage = VisionImage(image: image)
            self.visionObjectDetector.process(visionImage, completion: { detectObjects, error in
                if let error = error {
                    single(.failure(error))
                }
                
                guard let detectedObjects = detectObjects, !detectedObjects.isEmpty else {
                    single(.success([]))
                    return
                }
                
                single(.success(detectedObjects.uniqued()))
            })
            
            return Disposables.create()
        }
    }
}
