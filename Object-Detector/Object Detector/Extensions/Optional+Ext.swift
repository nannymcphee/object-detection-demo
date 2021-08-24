//
//  Optional+Ext.swift
//  Object Detector
//
//  Created by Duy Nguyen on 21/08/2021.
//

public extension Optional where Wrapped == String {
    var orEmpty: String {
        switch self {
        case .some(let value):
            return String(describing: value)
        default:
            return ""
        }
    }
}
