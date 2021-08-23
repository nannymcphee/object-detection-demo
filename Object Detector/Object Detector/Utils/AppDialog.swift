//
//  AppDialog.swift
//  Object Detector
//
//  Created by Duy Nguyen on 21/08/2021.
//

import UIKit

open class AppDialog {
    public static func development(controller: UIViewController) {
        let alert = UIAlertController(title: "", message: "Development", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        controller.present(alert, animated: true, completion: nil)
    }
    
    /**
     * notify with alert
     */
    public static func withOk(controller: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        controller.present(alert, animated: true, completion: nil)
    }
    
    /**
     * notify with OK action button
     */
    public static func withOk(controller: UIViewController, title: String, message: String,
                       ok: @escaping () -> Void) {
        
        let refreshAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (alertAction) in
            ok()
        }
        
        refreshAlert.addAction(okAction)
        controller.present(refreshAlert, animated: true, completion: nil)
    }
    
    /**
     * notify with alert plus action button
     */
    public static func withOkCancel(controller: UIViewController, title: String, message: String,
                             ok: @escaping () -> Void) {
        let refreshAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (alertAction) in
            ok()
        }
        refreshAlert.addAction(okAction)
        
        // Add cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        refreshAlert.addAction(cancelAction)
        
        controller.present(refreshAlert, animated: true, completion: nil)
    }
    
    public static func withInputNumber(controller: UIViewController, title: String, content: String?, ok: @escaping (String) -> Void) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = content
            textField.keyboardType = .numberPad
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            ok(textField?.text ?? "")
        }))
        
        controller.present(alert, animated: true, completion: nil)
    }
    
    public static func withInputField(controller: UIViewController,
                               title: String,
                               content: String? = nil,
                               placeholder: String?,
                               keyboardType: UIKeyboardType? = .default,
                               ok: @escaping (String) -> Void) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.clearButtonMode = .whileEditing
            textField.text = content
            textField.placeholder = placeholder
            textField.keyboardType = keyboardType ?? .default
            textField.autocapitalizationType = .sentences
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            ok(textField?.text ?? "")
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { alert in
            controller.dismiss(animated: true, completion: nil)
        }))
        
        controller.present(alert, animated: true, completion: nil)
    }
    
    public static func actionSheet(controller: UIViewController, title: String? = nil, message: String? = nil, actions: [UIAlertAction]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            alert.dismiss(animated: true, completion: nil)
        }
        actions.forEach { alert.addAction($0) }
        alert.addAction(cancelAction)
        alert.pruneNegativeWidthConstraints()
        controller.present(alert, animated: true, completion: nil)
    }
}

extension UIAlertController {
    func pruneNegativeWidthConstraints() {
        for subView in self.view.subviews {
            for constraint in subView.constraints where constraint.debugDescription.contains("width == - 16") {
                subView.removeConstraint(constraint)
            }
        }
    }
}
