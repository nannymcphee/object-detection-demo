//
//  ViewModelTransformable.swift
//  Object Detector
//
//  Created by Duy Nguyen on 30/08/2021.
//

protocol ViewModelTransformable: AnyObject {
    associatedtype Input
    associatedtype Output
    func transform(input: Input) -> Output
}
