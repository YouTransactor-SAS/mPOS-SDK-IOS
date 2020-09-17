//
//  TaskEvent.swift
//  uCube
//
//  Created by Rémi Hillairet on 5/22/20.
//  Copyright © 2020 YouTransactor. All rights reserved.
//

public enum TaskEvent {
    case progress
    case cancelled
    case success
    case failed
    
    var name: String {
        switch self {
        case .progress:
            return "progress"
        case .cancelled:
            return "cancelled"
        case .success:
            return "success"
        case .failed:
            return "failed"
        }
    }
}
