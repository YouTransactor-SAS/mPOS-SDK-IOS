//
//  Loggable.swift
//  uCube
//
//  Created by Rémi Hillairet on 5/21/20.
//  Copyright © 2020 YouTransactor. All rights reserved.
//

import os.log

public protocol Loggable {
    
    func debug(message: String, filePath: String, functionName: String)
    func error(message: String, error: Error?, filePath: String, functionName: String)
}

// Default implementation of Loggable, extension needed in order to use default parameters
extension Loggable {
    
    func getFileName(filePath: String) -> String {
        return URL(string: filePath)?.deletingPathExtension().lastPathComponent ?? ""
    }
    
    public func debug(message: String, filePath: String = #file, functionName: String = #function) {
        os_log("%@:%@ - %@", log: OSLog.uCube, type: .debug, getFileName(filePath: filePath), functionName, message)
    }
    
    public func error(message: String, error: Error? = nil, filePath: String = #file, functionName: String = #function) {
        os_log("%@:%@ - %@ %@", log: OSLog.uCube, type: .error, getFileName(filePath: filePath), functionName, message, error?.localizedDescription ?? "nil")
    }
}

extension OSLog {
    
    private static var subsystem = Bundle.main.bundleIdentifier!
    static let uCube = OSLog(subsystem: subsystem, category: "uCube")
}
