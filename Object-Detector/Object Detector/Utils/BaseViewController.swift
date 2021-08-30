//
//  BaseViewController.swift
//  Object Detector
//
//  Created by Duy Nguyen on 21/08/2021.
//

import RxSwift
import RxSwiftExt

class BaseViewController: UIViewController {    
    public var isSwipeBackEnabled: Bool = false {
        didSet {
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = isSwipeBackEnabled
        }
    }
    
    deinit {
        Logger.i("\(String(describing: type(of: self))) deinit", tag: "🔴🔴🔴🔴")
    }
    
    open func showLoading(loadingMessage: String? = nil) {
        DispatchQueue.main.async {
            LoadingViewHelper.showLoading(in: self.view,
                                          loadingMessage: loadingMessage)
        }
    }
    
    open func hideLoading() {
        DispatchQueue.main.async {
            LoadingViewHelper.hideLoading()
        }
    }
}

extension Reactive where Base: BaseViewController {
    var isLoading: Binder<Bool> { Binder(base) { $1 ? $0.showLoading() : $0.hideLoading() }}
}
