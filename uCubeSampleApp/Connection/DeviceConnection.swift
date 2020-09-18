//
//  DeviceConnection.swift
//  uCubeSampleApp
//
//  Created by Rémi Hillairet on 7/15/20.
//  Copyright © 2020 YouTransactor. All rights reserved.
//

import UIKit
import UCube

class DeviceConnection: ConnectionDelegate {
    
    var connectCompletion: (() -> Void)?
    var disconnectCompletion: (() -> Void)?
    
    init() {
        BLEConnectionManager.shared.connectionDelegate = self
    }
    
    deinit {
        BLEConnectionManager.shared.connectionDelegate = nil
    }
    
    func connect() {
        BLEConnectionManager.shared.connect()
    }
    
    func disconnect() {
        BLEConnectionManager.shared.disconnect()
    }
    
    // MARK: - ConnectionDelegate
    
    func deviceDidConnect(_ device: UCubeDevice) {
        connectCompletion?()
    }
    
    func deviceDidDisconnect(_ device: UCubeDevice) {
        disconnectCompletion?()
    }
    
    func deviceDidFailToConnect(_ device: UCubeDevice, error: Error?) {
        LogManager.debug(message: "Device did fail to connect: \(error?.localizedDescription ?? "nil")")
        disconnectCompletion?()
    }
}
