//
//  LogManager.swift
//  uCube
//
//  Created by Rémi Hillairet on 5/21/20.
//  Copyright © 2020 YouTransactor. All rights reserved.
//

public struct LogManager {
    
    public static var logger: Loggable = Logger()
    
    public static func debug(message: String, filePath: String = #file, functionName: String = #function) {
        LogManager.logger.debug(message: message, filePath: filePath, functionName: functionName)
    }
    
    public static func error(message: String, error: Error? = nil, filePath: String = #file, functionName: String = #function) {
        LogManager.logger.error(message: message, error: error, filePath: filePath, functionName: functionName)
    }
}
