//
//  CameraVM.swift
//  Object Detector
//
//  Created by Duy Nguyen on 30/08/2021.
//

import AVFoundation
import RxSwift
import RxCocoa

class CameraVM: BaseVM, ViewModelTransformable {
    // MARK: - Input
    struct Input {
        let pixelBuffer: Observable<CVPixelBuffer>
    }
    
    // MARK: - Output
    struct Output {
        let detectedObjects: Driver<[DetectedObjectModel]>
    }
    
    // MARK: - Variables
    private var objectDetector = CoreMLObjectDetector()
    private let detectedObjectsRelay = BehaviorRelay<[DetectedObjectModel]>(value: [])
    
    // MARK: - Public functions
    func transform(input: Input) -> Output {
        input.pixelBuffer
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .withUnretained(self)
            .flatMapLatest { viewModel, pixelBuffer in
                viewModel.objectDetector
                    .detectObjects(in: pixelBuffer)
                    .asObservable()
                    .catchErrorJustComplete()
            }
            .bind(to: detectedObjectsRelay)
            .disposed(by: disposeBag)
        
        return Output(detectedObjects: detectedObjectsRelay.asDriverOnErrorJustComplete())
    }
}
