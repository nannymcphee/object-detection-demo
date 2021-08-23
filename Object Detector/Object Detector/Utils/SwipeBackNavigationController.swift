//
//  SwipeBackNavigationController.swift
//  Object Detector
//
//  Created by Duy Nguyen on 21/08/2021.
//

import UIKit

open class SwipeBackNavigationController: UINavigationController {
    
    // MARK: - Lifecycle
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        
        delegate = self
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        delegate = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        delegate = self
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }
    
    deinit {
        delegate = nil
        interactivePopGestureRecognizer?.delegate = nil
    }
    
    // MARK: - Overrides
    open override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        duringPushAnimation = true
        super.pushViewController(viewController, animated: animated)
    }
    
    // MARK: - Private Properties
    
    fileprivate var duringPushAnimation = false
    
}

// MARK: - Extensions
extension SwipeBackNavigationController: UINavigationControllerDelegate {
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let swipeNavigationController = navigationController as? SwipeBackNavigationController else { return }
        swipeNavigationController.duringPushAnimation = false
    }
}

extension SwipeBackNavigationController: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer == interactivePopGestureRecognizer else {
            return true
        }
        return viewControllers.count > 1 && duringPushAnimation == false
    }
}
