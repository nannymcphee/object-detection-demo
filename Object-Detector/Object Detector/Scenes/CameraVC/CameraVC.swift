//
//  CameraVC.swift
//  Object Detector
//
//  Created by Duy Nguyen on 21/08/2021.
//

import UIKit
import AVFoundation
import RxSwift
import RxCocoa

class CameraVC: RxBaseViewController<CameraVM> {
    // MARK: - IBOutlets
    @IBOutlet weak var vDrawing: DrawingView!
    @IBOutlet weak var vPreview: UIView!
    
    // MARK: - Variables
    private var videoCapture: VideoCapture!
    private var cameraSetupSuccess: Bool = false
    private var isInference = false
    
    private let pixelBufferSubject = PublishSubject<CVPixelBuffer>()
    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setUpCamera()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        checkCameraAuthStatus()
        if cameraSetupSuccess {
            videoCapture.start()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
        UIApplication.shared.isIdleTimerDisabled = false
        if cameraSetupSuccess {
            videoCapture.stop()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        resizePreviewLayer()
    }
    
    // MARK: - Private functions
    private func bindViewModel() {
        let input = Input(pixelBuffer: pixelBufferSubject)
        let output = viewModel.transform(input: input)
        
        // Detected objects
        output.detectedObjects
            .drive(with: self, onNext: { viewController, objects in
                viewController.vDrawing.predictedObjects = objects
                viewController.isInference = false
            })
            .disposed(by: disposeBag)
    }
    
    private func setUpUI() {
        title = "Camera"
    }
    
    private func setUpCamera() {
        videoCapture = VideoCapture()
        videoCapture.delegate = self
        videoCapture.fps = 30
        videoCapture.setUp(sessionPreset: .hd1280x720) { [weak self] success in
            guard let self = self else { return }
            
            self.cameraSetupSuccess = success
            
            if success {
                // add preview view on the layer
                if let previewLayer = self.videoCapture.previewLayer {
                    self.vPreview.layer.addSublayer(previewLayer)
                    self.resizePreviewLayer()
                }
                
                // start video preview when setup is done
                self.videoCapture.start()
            }
        }
    }
    
    private func resizePreviewLayer() {
        videoCapture.previewLayer?.frame = vPreview.bounds
    }
    
    private func checkCameraAuthStatus() {
        if AVCaptureDevice.authorizationStatus(for: .video) !=  .authorized {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { [weak self] (granted) in
                guard let self = self else { return }
                
                if !granted {
                    DispatchQueue.main.async {
                        AppDialog.withOkCancel(controller: self,
                                               title: "Go to Settings",
                                               message: "Enable Camera in Settings", ok: {
                            UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
                        })
                    }
                }
            })
        }
    }
}

// MARK: - Extensions
extension CameraVC: VideoCaptureDelegate {
    func videoCapture(_ capture: VideoCapture, didCaptureVideoFrame pixelBuffer: CVPixelBuffer?, timestamp: CMTime) {
        // the captured image from camera is contained on pixelBuffer
        if !isInference, let pixelBuffer = pixelBuffer {
            isInference = true
            pixelBufferSubject.onNext(pixelBuffer)
        }
    }
}
