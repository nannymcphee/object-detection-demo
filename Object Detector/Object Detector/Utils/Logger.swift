//
//  Logger.swift
//  Object Detector
//
//  Created by Duy Nguyen on 21/08/2021.
//

import Foundation

public enum LogLevel: String {
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
}

public class Logger {
    
    public static let TAG: String = "Logger"
    #if DEBUG
    private static let isDebug = true
    #else
    private static let isDebug = false
    #endif
    
    private init() {}
    
    public static func d(_ object: Any?,
                             tag: String? = nil,
                             file: String = #file,
                             function: String = #function,
                             line: Int = #line) {
        let _tag = tag ?? "🟠🟠🟠🟠"
        self.print(tag: _tag, level: .debug, message: String(describing: object ?? "nil"), file: file, function: function, line: line)
    }
    
    public static func i(_ object: Any?,
                             tag: String? = nil,
                             file: String = #file,
                             function: String = #function,
                             line: Int = #line) {
        let _tag = tag ?? "ℹ️"
        self.print(tag: _tag, level: .info, message: String(describing: object ?? "nil"), file: file, function: function, line: line)
    }
    
    public static func w(_ object: Any?,
                             tag: String? = nil,
                             file: String = #file,
                             function: String = #function,
                             line: Int = #line) {
        let _tag = tag ?? "🔵🔵🔵🔵"
        self.print(tag: _tag, level: .warning, message: String(describing: object ?? "nil"), file: file, function: function, line: line)
    }
    
    public static func e(_ object: Any?,
                             tag: String? = nil,
                             file: String = #file,
                             function: String = #function,
                             line: Int = #line) {
        let _tag = tag ?? "❌❌❌❌"
        self.print(tag: _tag, level: .error, message: String(describing: object ?? "nil"), file: file, function: function, line: line)
    }
    
    private static func print(tag: String?,
                              level: LogLevel,
                              message: String?,
                              file: String = #file,
                              function: String = #function,
                              line: Int = #line) {
        if isDebug {
            let filename = (file as NSString).lastPathComponent
            let threadName: String = Thread.isMainThread ?
                "MAIN" :
                "BG"
            NSLog("[%@] [%@] %@:%@ %@ - %@: %@", threadName, level.rawValue, filename, String(line), function, tag ?? TAG, message ?? "")
        }
    }
}
