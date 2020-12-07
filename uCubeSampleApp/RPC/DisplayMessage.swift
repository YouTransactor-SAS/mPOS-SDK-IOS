//
//  DisplayMessage.swift
//  uCubeSampleApp
//
//  Created by Rémi Hillairet on 7/15/20.
//  Copyright © 2020 YouTransactor. All rights reserved.
//

import UCube

struct DisplayMessage {
    
    func display(_ message: String, completion: @escaping (_ success: Bool, _ message: String?) -> Void) {
        let exitSecureSession = ExitSecureSessionCommand() // if device is in secure state back to ready state befaore calling display
        exitSecureSession.execute(monitor: TaskMonitor(eventHandler: { (event: TaskEvent, parameters: [Any]) in
            switch event {
            case .failed:
                 LogManager.debug(message: "Displaying \(message) failed")
                 completion(false, "Command failed")
            case .cancelled:
                 LogManager.debug(message: "Displaying \(message) cancelled")
                 completion(false, "Command cancelled")
            case .success:
                let command = DisplayMessageCommand(message: message)
                command.setTimeout(5)
                command.setClearConfig(1)
                command.execute(monitor: TaskMonitor(eventHandler: { (event: TaskEvent, parameters: [Any]) in
                    switch event {
                    case .failed:
                         LogManager.debug(message: "Displaying \(message) failed")
                         completion(false, "Command failed")
                    case .cancelled:
                         LogManager.debug(message: "Displaying \(message) cancelled")
                         completion(false, "Command cancelled")
                    case .success:
                        LogManager.debug(message: "Displaying \(message) succeeded")
                        completion(true, "Command succeeded")
                    default:
                        break
                    }
                }))
            default:
                break
            }
        }))
       
    }
}
