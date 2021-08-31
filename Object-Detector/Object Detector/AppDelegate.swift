//
//  AppDelegate.swift
//  Object Detector
//
//  Created by Duy Nguyen on 21/08/2021.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    internal var window: UIWindow?
    private var navigationController: SwipeBackNavigationController?
    private var rootViewController: UIViewController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        initRootVC()
        // Prevents the app from going to sleep
        UIApplication.shared.isIdleTimerDisabled = true
        return true
    }
    
    private func initRootVC() {
        rootViewController = HomeVC(viewModel: HomeVM())
        navigationController = SwipeBackNavigationController(rootViewController: rootViewController!)
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    
    public func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .portrait
    }
}

