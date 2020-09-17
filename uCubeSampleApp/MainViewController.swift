//
//  MainViewController.swift
//  uCubeSampleApp
//
//  Created by Rémi Hillairet on 7/10/20.
//  Copyright © 2020 YouTransactor. All rights reserved.
//

import UIKit
import UCube

class MainViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var identifierLabel: UILabel!
    @IBOutlet weak var appVersionLabel: UILabel!
    @IBOutlet weak var frameworkVersionLabel: UILabel!
    
    var device: UCubeDevice? {
        didSet {
            if let device = device {
                BLEConnectionManager.shared.setDevice(device)
                UserDefaults.standard.set(device.identifier.uuidString, forKey: "LastDeviceIdentifierString")
                nameLabel.text = "Name: \(device.name)"
                identifierLabel.text = "Identifier: \(device.identifier.uuidString)"
            } else {
                nameLabel.text = ""
                identifierLabel.text = ""
            }
            if let menuVC = children[0] as? MenuTableViewController {
                menuVC.updateMDMButtons()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        device = nil
        if
            let lastDeviceIdentifierString = UserDefaults.standard.value(forKey: "LastDeviceIdentifierString") as? String,
            let identifier = UUID(uuidString: lastDeviceIdentifierString)
        {
            BLEConnectionManager.shared.setDevice(identifier: identifier) { device in
                self.device = device
                if device == nil {
                    LogManager.debug(message: "No device found with identifier: \(identifier)")
                }
            }
        }
        appVersionLabel.text = "UCube Example v\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "")"
        frameworkVersionLabel.text = "UCube Framework v\(Bundle(for: BLEConnectionManager.self).infoDictionary?["CFBundleShortVersionString"] ?? "")"
    }
}
