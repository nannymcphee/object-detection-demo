//
//  Observable+Ext.swift
//  Object Detector
//
//  Created by Duy Nguyen on 21/08/2021.
//

import RxCocoa
import RxSwift

public protocol OptionalType {
    associatedtype Wrapped
    
    var value: Wrapped? { get }
}

extension Optional: OptionalType {
    public var value: Wrapped? {
        return self
    }
}

public extension Observable where Element: OptionalType {
    func filterNil() -> Observable<Element.Wrapped> {
        return flatMap { (element) -> Observable<Element.Wrapped> in
            if let value = element.value {
                return .just(value)
            } else {
                return .empty()
            }
        }
    }
    
    func filterNilKeepOptional() -> Observable<Element> {
        return self.filter { (element) -> Bool in
            return element.value != nil
        }
    }
    
    func replaceNil(with nilValue: Element.Wrapped) -> Observable<Element.Wrapped> {
        return flatMap { (element) -> Observable<Element.Wrapped> in
            if let value = element.value {
                return .just(value)
            } else {
                return .just(nilValue)
            }
        }
    }
}

public protocol BooleanType {
    var boolValue: Bool { get }
}
extension Bool: BooleanType {
    public var boolValue: Bool { return self }
}

// Maps true to false and vice versa
public extension Observable where Element: BooleanType {
    func not() -> Observable<Bool> {
        return self.map { input in
            return !input.boolValue
        }
    }
}

public extension Observable where Element: Equatable {
    func ignore(value: Element) -> Observable<Element> {
        return filter { (selfE) -> Bool in
            return value != selfE
        }
    }
}

public extension ObservableType where Element == Bool {
    /// Boolean not operator
    func not() -> Observable<Bool> {
        return self.map(!)
    }
}

public extension ObservableType {
    func catchErrorJustComplete() -> Observable<Element> {
        return catchError { _ in
            return Observable.empty()
        }
    }
    
    func mapToVoid() -> Observable<Void> {
        return map { _ in }
    }
    
    func asDriverOnErrorJustComplete() -> Driver<Element> {
        return asDriver { error in
            assertionFailure("Error \(error)")
            return Driver.empty()
        }
    }
}
