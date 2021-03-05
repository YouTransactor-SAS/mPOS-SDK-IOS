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
        let command = DisplayMessageCommand(message: message)
        //command.setClearConfig(1)
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
            
       
    }
}
