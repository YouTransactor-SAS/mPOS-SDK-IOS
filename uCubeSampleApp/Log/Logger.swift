//
//  Logger.swift
//  uCube
//
//  Created by Rémi Hillairet on 5/21/20.
//  Copyright © 2020 YouTransactor. All rights reserved.
//

import os.log
import Zip

public struct Logger: Loggable {

    private let fileName = "messages.log"
    private let cycleFileNameFormat = "message.%d.log"
    private let cycleRange = 1...5
    private let maxFileSize = 2000000 // 2MB
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
    private let folderURL: URL = {
        let cachesFolderPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
        let cachesFolderURL = URL(fileURLWithPath: cachesFolderPath)
        return cachesFolderURL
            .appendingPathComponent("uCube", isDirectory: true)
            .appendingPathComponent("logs", isDirectory: true)
    }()
    
    init() {
        createLogsDirectory()
    }
    
    public func hasLogs() -> Bool {
        if !FileManager.default.fileExists(atPath: folderURL.appendingPathComponent(fileName).path) {
            return false
        }
        return true
    }
    
    public func getLogs() -> (fileData: Data, fileType: String)? {
        guard hasLogs() else {
            log(type: .error, message: "There is no log")
            return nil
        }
        do {
            let zipURL = folderURL.deletingLastPathComponent().appendingPathComponent("logs.zip")
            try Zip.zipFiles(paths: [folderURL], zipFilePath: zipURL, password: nil, progress: nil)
            let zipData = try Data(contentsOf: zipURL)
            try FileManager.default.removeItem(at: zipURL)
            return (zipData, "zip")
        } catch {
            log(type: .error, message: "Get logs error", error: error)
        }
        return nil
    }
    
    public func deleteLogs() {
        do {
            for fileURL in try FileManager.default.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil) {
                try FileManager.default.removeItem(at: fileURL)
            }
        } catch {
            log(type: .error, message: "Can't delete logs", error: error)
        }
    }
    
    public func debug(message: String, filePath: String = #file, functionName: String = #function) {
        let fileName = getFileName(filePath: filePath)
        log(type: .debug, message: message, filePath: filePath, functionName: functionName)
        writeToFile(message: "\(fileName):\(functionName) - \(message)")
    }
    
    public func error(message: String, error: Error? = nil, filePath: String = #file, functionName: String = #function) {
        let fileName = getFileName(filePath: filePath)
        log(type: .error, message: message, error: error, filePath: filePath, functionName: functionName)
        writeToFile(message: "\(fileName):\(functionName) - \(message): \(error?.localizedDescription ?? "nil")")
    }
    
    private func log(type: OSLogType, message: String, error: Error? = nil, filePath: String = #file, functionName: String = #function) {
        if let error = error {
            os_log("%@:%@ - %@: %@", log: OSLog.uCube, type: .error, getFileName(filePath: filePath), functionName, message, error.localizedDescription)
        } else {
            os_log("%@:%@ - %@", log: OSLog.uCube, type: .error, getFileName(filePath: filePath), functionName, message)
        }
    }
    
    private func createLogsDirectory() {
        do {
            try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            log(type: .error, message: "Can't create logs directory", error: error)
        }
    }
    
    private func cycleLogFiles() {
        do {
            for i in cycleRange.reversed() {
                let originalFileURL = folderURL.appendingPathComponent(String(format: cycleFileNameFormat, i))
                guard FileManager.default.fileExists(atPath: originalFileURL.path) else {
                    continue
                }
                if i == cycleRange.upperBound {
                    try FileManager.default.removeItem(at: originalFileURL)
                } else {
                    let newFileURL = folderURL.appendingPathComponent(String(format: cycleFileNameFormat, i + 1))
                    try FileManager.default.moveItem(at: originalFileURL, to: newFileURL)
                }
            }
            let originalFileURL = folderURL.appendingPathComponent(fileName)
            let newFileURL = folderURL.appendingPathComponent(String(format: cycleFileNameFormat, cycleRange.lowerBound))
            try FileManager.default.moveItem(at: originalFileURL, to: newFileURL)
        } catch {
            log(type: .error, message: "Cycle file logs failed", error: error)
        }
    }
    
    private func writeToFile(message: String) {
        let dateFormatted = dateFormatter.string(from: Date())
        guard let data = "\(dateFormatted) \(message)\n".data(using: .utf8) else {
            log(type: .error, message: "Can't create log data")
            return
        }
        let fileURL = folderURL.appendingPathComponent(fileName)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            // Check log file size
            do {
                let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
                if
                    let fileSize = attributes[.size] as? NSNumber,
                    fileSize.intValue > maxFileSize
                {
                    cycleLogFiles()
                }
            } catch {
                log(type: .error, message: "Can't get log file attributes", error: error)
            }
        }
        // Write to log file
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                let fileHandle = try FileHandle(forWritingTo: fileURL)
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                fileHandle.closeFile()
            } catch {
                log(type: .error, message: "Can't write to log file", error: error)
            }
        } else {
            do {
                try data.write(to: fileURL)
            } catch {
                log(type: .error, message: "Can't write to log file", error: error)
            }
        }
    }
}
