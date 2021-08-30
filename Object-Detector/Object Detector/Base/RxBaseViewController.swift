//
//  RxBaseViewController.swift
//  Object Detector
//
//  Created by Duy Nguyen on 30/08/2021.
//

import UIKit
import RxSwift

class RxBaseViewController<T: ViewModelTransformable>: BaseViewController {
    typealias Input = T.Input
    
    let viewModel: T
    let disposeBag = DisposeBag()
    
    init(viewModel: T, nibName: String? = nil) {
        self.viewModel = viewModel
        super.init(nibName: nibName, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
