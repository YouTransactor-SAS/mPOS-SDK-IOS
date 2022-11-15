/*============================================================================

* Copyright © 2022 YouTransactor.
* All Rights Reserved.
*
* This software is the confidential and proprietary information of YouTransactor
* ("Confidential Information"). You  shall not disclose or redistribute such
* Confidential Information and shall use it only in accordance with the terms of
* the license agreement you entered into with YouTransactor.
*
* This software is provided by YouTransactor AS IS, and YouTransactor
* makes no representations or warranties about the suitability of the software,
* either express or implied, including but not limited to the implied warranties
* of merchantability, fitness for a particular purpose or non-infringement.
* YouTransactor shall not be liable for any direct, indirect, incidental,
* special, exemplary, or consequential damages suffered by licensee as the
* result of using, modifying or distributing this software or its derivatives.
*
*==========================================================================*/

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
        frameworkVersionLabel.text = "UCube Framework v\(UCubeAPI.getVersionName())"
        
        BLEConnectionManager.shared.registerBatteryLevelChangedListener(batteryLevelListener:{(newLevel: UInt8) in
            LogManager.debug(message: "Received Terminal Battery level : \(newLevel)%")
        })
        
        BLEConnectionManager.shared.registerConnectionStateListener(connectionStateListener: {( newState: ConnectionState) in
            LogManager.debug(message: "Connection state changed listener : \(newState)")
        })
        
        BLEConnectionManager.shared.registerSVPPRestartListener {
            LogManager.debug(message: "Device crashed")
        }
    }
}
