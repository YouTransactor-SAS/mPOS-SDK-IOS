//
//  Task.swift
//  uCube
//
//  Created by Rémi Hillairet on 5/22/20.
//  Copyright © 2020 YouTransactor. All rights reserved.
//

public class Task: Tasking {
    
    var monitor: TaskMonitoring?
    
    public final func execute(monitor: TaskMonitoring) {
        self.monitor = monitor
        start()
    }
    
    func start() {
        fatalError("This method must be overriden by the subclass")
    }
    
    func notifyMonitor(event: TaskEvent, parameters: [Any] = []) {
        monitor?.eventHandler(event, parameters)
    }
}
