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
    let confidence: Float
    
    init(object: VNRecognizedObjectObservation) {
        self.label = object.label
        self.confidence = object.confidence
        self.boundingBox = object.boundingBox
    }
}
