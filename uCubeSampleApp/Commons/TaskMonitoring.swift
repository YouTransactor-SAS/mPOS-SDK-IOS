//
//  TaskMonitoring.swift
//  uCube
//
//  Created by Rémi Hillairet on 5/22/20.
//  Copyright © 2020 YouTransactor. All rights reserved.
//

//public typealias TaskMonitoring = ((_ event: TaskEvent, _ parameters: [Any] = []) -> Void)

public protocol TaskMonitoring {
    
    var eventHandler: ((_ event: TaskEvent, _ parameters: [Any]) -> Void) { get set }
}
