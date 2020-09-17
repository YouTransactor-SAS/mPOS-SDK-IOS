//
//  TaskMonitor.swift
//  uCube
//
//  Created by Rémi Hillairet on 5/28/20.
//  Copyright © 2020 YouTransactor. All rights reserved.
//

public struct TaskMonitor: TaskMonitoring {
    
    public var eventHandler: ((_ event: TaskEvent, _ parameters: [Any]) -> Void)
    
    public init(eventHandler: @escaping ((_ event: TaskEvent, _ parameters: [Any]) -> Void)) {
        self.eventHandler = eventHandler
    }
}
