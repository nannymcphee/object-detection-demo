//
//  HomeVC.swift
//  Object Detector
//
//  Created by Duy Nguyen on 21/08/2021.
//

import UIKit
import RxSwift
import RxCocoa

class HomeVC: BaseViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var btnLibrary: UIButton!
    @IBOutlet weak var btnCamera: UIButton!
    @IBOutlet weak var tvResult: UITextView!
    @IBOutlet weak var lbResultCount: UILabel!
    
    // MARK: - Variables
    private lazy var mediaPicker = RxMediaPicker(delegate: self)
    
    private var videoProcessor: VideoProcessor!
    private var objectDetector = CoreMLObjectDetector()
    private var startTime = Date()
    private var finishedTime = Date()
    
    private let loadingIndicator = ActivityIndicator()
    private let videoURLRelay = BehaviorRelay<URL?>(value: nil)
    private let detectedObjectsRelay = BehaviorRelay<[DetectedObjectModel]>(value: [])
    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        bindingUI()
    }
    
    private func setUpUI() {
        title = "Object Detection Demo"
        
        [btnLibrary, btnCamera].forEach {
            $0?.customRounded(border: 1.0, color: .clear)
            $0?.setTitleColor(.white, for: .normal)
        }
        
        btnLibrary.backgroundColor = .blue
        btnCamera.backgroundColor = .green
    }
    
    private func initVideoProcessor(with url: URL) {
        guard videoProcessor == nil else {
            videoProcessor.updateVideoURL(url)
            return
        }
        
        videoProcessor = VideoProcessor(url: url)
    }
    
    // MARK: - Private functions
    private func bindingUI() {
        // Photo library tap
        btnLibrary.rx.tap
            .withUnretained(self)
            .flatMap { $0.0.mediaPicker.selectVideo(maximumDuration: 180) }
            .catchErrorJustComplete()
            .bind(to: videoURLRelay)
            .disposed(by: disposeBag)
        
        // Live camera tap
        btnCamera.rx.tap
            .asDriver()
            .drive(with: self, onNext: { viewController, _ in
                let cameraVC = CameraVC()
                viewController.navigationController?.pushViewController(cameraVC, animated: true)
            })
            .disposed(by: disposeBag)
        
        // Loading indicator
        loadingIndicator
            .drive(rx.isLoading)
            .disposed(by: disposeBag)
        
        /*
         1. Initialize videoProcessor after retrieved selected video's URL
         2. Get all frames ([CGImages]) from video
         3. Perform object detection in each frame
         */
        videoURLRelay
            .unwrap()
            .do(onNext: { [weak self] url in
                guard let self = self else { return }
                self.tvResult.text = ""
                self.lbResultCount.text = ""
                self.startTime = Date()
                self.initVideoProcessor(with: url)
            })
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .withUnretained(self)
            .flatMapLatest { viewController, _ -> Observable<[DetectedObjectModel]> in
                viewController.videoProcessor
                    .getAllFramesFromVideo()
                    .asObservable()
                    .flatMapLatest {
                        return viewController.objectDetector
                            .detectObjects(in: $0)
                            .trackActivity(viewController.loadingIndicator)
                            .catchErrorJustComplete()
                    }
                    .trackActivity(viewController.loadingIndicator)
                    .catchErrorJustComplete()
            }
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.finishedTime = Date()
            })
            .bind(to: detectedObjectsRelay)
            .disposed(by: disposeBag)
        
        // Binding lbResult's text
        let detectedObjectsobservable = detectedObjectsRelay
            .skip(1)
            .share()

        detectedObjectsobservable
            .withUnretained(self)
            .map { viewController, objects -> String in
                let interval = viewController.finishedTime - viewController.startTime
                let suffix = "total time: \(interval.second ?? 0)s"
                return objects.isEmpty
                    ? "No object detected, \(suffix)"
                    : "Detected \(objects.count) objects, \(suffix)"
            }
            .asDriverOnErrorJustComplete()
            .drive(lbResultCount.rx.text)
            .disposed(by: disposeBag)
            
        // Binding tvResult's text
        detectedObjectsobservable
            .filter { !$0.isEmpty }
            .map { objects in
                return objects.enumerated().map { object -> String in
                    let confidence = Int((object.element.confidence) * 100)
                    return "\(object.offset + 1).\t\(object.element.label), confidence: \(confidence)%"
                }
                .joined(separator: "\n")
            }
            .asDriverOnErrorJustComplete()
            .drive(tvResult.rx.text)
            .disposed(by: disposeBag)
    }
}

// MARK: - Extensions
extension HomeVC: RxMediaPickerDelegate {
    func present(picker: UIImagePickerController) {
        present(picker, animated: true, completion: nil)
    }
    
    func dismiss(picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
