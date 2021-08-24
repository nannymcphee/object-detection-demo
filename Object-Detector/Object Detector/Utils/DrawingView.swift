//
//  DrawingView.swift
//  Object Detector
//
//  Created by Duy Nguyen on 21/08/2021.
//

import UIKit

class DrawingView: UIView {
    static private var colors: [String: UIColor] = [:]
    
    public func labelColor(with label: String) -> UIColor {
        if let color = DrawingView.colors[label] {
            return color
        } else {
            let color = UIColor(hue: .random(in: 0...1), saturation: 1, brightness: 1, alpha: 0.8)
            DrawingView.colors[label] = color
            return color
        }
    }
    
    public var predictedObjects: [DetectedObjectModel] = [] {
        didSet {
            self.drawBoxs(with: predictedObjects)
            self.setNeedsDisplay()
        }
    }
    
    func drawBoxs(with predictions: [DetectedObjectModel]) {
        subviews.forEach({ $0.removeFromSuperview() })
        
        for prediction in predictions {
            createLabelAndBox(prediction: prediction)
        }
    }
    
    func createLabelAndBox(prediction: DetectedObjectModel) {
        let confidence = Int((prediction.confidence) * 100)
        let labelString: String = "\(prediction.label): \(confidence)%"
        let color: UIColor = labelColor(with: labelString)
        
        let scale = CGAffineTransform.identity.scaledBy(x: bounds.width, y: bounds.height)
        let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -1)
        let bgRect = prediction.boundingBox.applying(transform).applying(scale)
        
        let bgView = UIView(frame: bgRect)
        bgView.layer.borderColor = color.cgColor
        bgView.layer.borderWidth = 4
        bgView.backgroundColor = UIColor.clear
        addSubview(bgView)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        label.text = labelString
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.black
        label.backgroundColor = color
        label.sizeToFit()
        label.frame = CGRect(x: bgRect.origin.x, y: bgRect.origin.y - label.frame.height,
                             width: label.frame.width, height: label.frame.height)
        addSubview(label)
    }
}

extension CGRect {
    func toString(digit: Int) -> String {
        let xStr = String(format: "%.\(digit)f", origin.x)
        let yStr = String(format: "%.\(digit)f", origin.y)
        let wStr = String(format: "%.\(digit)f", width)
        let hStr = String(format: "%.\(digit)f", height)
        return "(\(xStr), \(yStr), \(wStr), \(hStr))"
    }
}

