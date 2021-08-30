//
//  HomeVC.swift
//  Object Detector
//
//  Created by Duy Nguyen on 21/08/2021.
//

import UIKit
import RxSwift

class HomeVC: RxBaseViewController<HomeVM> {
    // MARK: - IBOutlets
    @IBOutlet weak var btnLibrary: UIButton!
    @IBOutlet weak var btnCamera: UIButton!
    @IBOutlet weak var tvResult: UITextView!
    @IBOutlet weak var lbResultCount: UILabel!
    
    // MARK: - Variables
    private lazy var mediaPicker = RxMediaPicker(delegate: self)
    
    private let selectedVideoURL = PublishSubject<URL?>()
    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        bindViewModel()
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
    
    // MARK: - Private functions
    private func bindViewModel() {
        let input = Input(selectedVideoURL: selectedVideoURL)
        let output = viewModel.transform(input: input)
        
        // Binding tvResult's text
        output.detectedObjectsCountText
            .drive(lbResultCount.rx.text)
            .disposed(by: disposeBag)
        
        // Binding tvResult's text
        output.detectedObjectsInfoText
            .drive(tvResult.rx.text)
            .disposed(by: disposeBag)
        
        // Loading indicator
        output.isLoading
            .drive(rx.isLoading)
            .disposed(by: disposeBag)
    }
    
    private func bindingUI() {
        // Photo library tap
        btnLibrary.rx.tap
            .withUnretained(self)
            .flatMap { $0.0.mediaPicker.selectVideo(maximumDuration: 180) }
            .catchErrorJustComplete()
            .bind(to: selectedVideoURL)
            .disposed(by: disposeBag)
        
        // Reset text
        selectedVideoURL.unwrap()
            .subscribe(with: self, onNext: { viewController, _ in
                viewController.tvResult.text = ""
                viewController.lbResultCount.text = ""
            })
            .disposed(by: disposeBag)
        
        // Live camera tap
        btnCamera.rx.tap
            .asDriver()
            .drive(with: self, onNext: { viewController, _ in
                let cameraVC = CameraVC(viewModel: CameraVM())
                viewController.navigationController?.pushViewController(cameraVC, animated: true)
            })
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
