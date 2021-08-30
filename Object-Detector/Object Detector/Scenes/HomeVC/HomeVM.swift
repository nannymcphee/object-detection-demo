//
//  HomeVM.swift
//  Object Detector
//
//  Created by Duy Nguyen on 30/08/2021.
//

import RxSwift
import RxCocoa

class HomeVM: BaseVM, ViewModelTransformable {
    // MARK: - Input
    struct Input {
        let selectedVideoURL: Observable<URL?>
    }
    
    // MARK: - Output
    struct Output {
        let detectedObjectsCountText: Driver<String>
        let detectedObjectsInfoText: Driver<String>
        let isLoading: Driver<Bool>
    }
    
    // MARK: - Variables
    private var startTime = Date()
    private var finishedTime = Date()
    private var videoProcessor: VideoProcessor!
    private var objectDetector = CoreMLObjectDetector()
    
    private let loadingIndicator = ActivityIndicator()
    private let detectedObjectsRelay = BehaviorRelay<[DetectedObjectModel]>(value: [])
    
    // MARK: - Public functions
    func transform(input: Input) -> Output {
        /*
         1. Initialize videoProcessor after retrieved selected video's URL
         2. Get all frames ([CGImages]) from video
         3. Perform object detection in each frame
         */
        input.selectedVideoURL
            .unwrap()
            .do(onNext: { [weak self] url in
                guard let self = self else { return }
                self.startTime = Date()
                self.initVideoProcessor(with: url)
            })
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .withUnretained(self)
            .flatMapLatest { viewModel, _ -> Observable<[CGImage]> in
                viewModel.videoProcessor
                    .getAllFramesFromVideo()
                    .trackActivity(viewModel.loadingIndicator)
                    .catchErrorJustComplete()
            }
            .withUnretained(self)
            .flatMapLatest { viewModel, frames -> Observable<[DetectedObjectModel]> in
                return viewModel.objectDetector
                    .detectObjects(in: frames)
                    .trackActivity(viewModel.loadingIndicator)
                    .catchErrorJustComplete()
            }
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.finishedTime = Date()
            })
            .bind(to: detectedObjectsRelay)
            .disposed(by: disposeBag)
        
        let detectedObjectsobservable = detectedObjectsRelay
            .skip(1)
            .share()

        // Generate lbResult's text
        let detectedObjectsCountText = detectedObjectsobservable
            .withUnretained(self)
            .map { viewModel, objects -> String in
                let interval = viewModel.finishedTime - viewModel.startTime
                let suffix = "total time: \(interval.second ?? 0)s"
                return objects.isEmpty
                    ? "No object detected, \(suffix)"
                    : "Detected \(objects.count) objects, \(suffix)"
            }
            .asDriverOnErrorJustComplete()
            
        // Generate tvResult's text
        let detectedObjectsInfoText = detectedObjectsobservable
            .filter { !$0.isEmpty }
            .map { objects in
                return objects.enumerated().map { object -> String in
                    let confidence = Int((object.element.confidence) * 100)
                    return "\(object.offset + 1).\t\(object.element.label), confidence: \(confidence)%"
                }
                .joined(separator: "\n")
            }
            .asDriverOnErrorJustComplete()
        
        return Output(detectedObjectsCountText: detectedObjectsCountText,
                      detectedObjectsInfoText: detectedObjectsInfoText,
                      isLoading: loadingIndicator.asDriver())
    }
}

// MARK: - Private functions
private extension HomeVM {
    func initVideoProcessor(with url: URL) {
        guard videoProcessor == nil else {
            videoProcessor.updateVideoURL(url)
            return
        }
        videoProcessor = VideoProcessor(url: url)
    }
}
