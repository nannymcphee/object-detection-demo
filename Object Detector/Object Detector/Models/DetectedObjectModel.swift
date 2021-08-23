//
//  DetectedObjectModel.swift
//  Object Detector
//
//  Created by Duy Nguyen on 22/08/2021.
//

import Vision

struct DetectedObjectModel {
    let label: String
    let boundingBox: CGRect
    let confidence: Double
    
    init(object: VNRecognizedObjectObservation) {
        self.label = object.label
        self.confidence = Double(object.confidence)
        self.boundingBox = object.boundingBox
    }
}
