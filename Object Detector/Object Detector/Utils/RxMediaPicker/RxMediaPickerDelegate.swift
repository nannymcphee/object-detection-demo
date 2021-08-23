//
//  RxMediaPickerDelegate.swift
//  Object Detector
//
//  Created by Duy Nguyen on 21/08/2021.
//

import RxSwift
import UIKit

extension RxMediaPickerDelegate where Self: UIViewController {
    func present(picker: UIImagePickerController) {
        self.present(picker, animated: true, completion: .none)
    }

    func dismiss(picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: .none)
    }
}
