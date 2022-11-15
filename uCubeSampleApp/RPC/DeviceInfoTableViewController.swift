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

class DeviceInfoTableViewController: UITableViewController {
    
    var deviceInfo: DeviceInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        let tags = [
            RPC.Tag.terminalPN,
            RPC.Tag.terminalSN,
            RPC.Tag.firmwareVersion,
            RPC.Tag.emvICCConfigVersion,
            RPC.Tag.emvNFCConfigVersion,
            RPC.Tag.terminalState,
            RPC.Tag.batteryState,
            RPC.Tag.powerOffTimeout,
            RPC.Tag.osVersion,
            RPC.Tag.supportedLocaleList,
            RPC.Tag.configurationMerchantInterfaceLocale,
            RPC.Tag.terminalChargingStatus,
            RPC.Tag.bleFirmwareVersion,
            RPC.Tag.resourcesFileVersion,
            RPC.Tag.speedMode,
            RPC.Tag.buildConfiguration,
            RPC.Tag.nonSecureFirmwareVersion
        ]
        let uInt8Tags = tags.map{ UInt8($0) }
        let command = GetInfoCommand(tags: uInt8Tags)
        command.execute(monitor: TaskMonitor(eventHandler: { (event: TaskEvent, parameters: [Any]) in
            switch event {
            case .failed, .cancelled:
                print("get info failed with status \(event)")
                self.deviceInfo = DeviceInfo(tlv: Data())
                self.tableView.tableHeaderView = nil
                self.tableView.reloadData()
                break
            case .success:
                self.deviceInfo = DeviceInfo(tlv: (parameters[0] as! GetInfoCommand).getResponseData() ?? Data())
                self.tableView.tableHeaderView = nil
                self.tableView.reloadData()
            default:
                break
            }
        }))
     
        tableView.contentInset.top = 20
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        guard deviceInfo != nil else {
            return 0
        }
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard deviceInfo != nil else {
            return 0
        }
        return 17
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "deviceInfoCell", for: indexPath)

        var text = ""
        switch indexPath.row {
        case 0:
            text = "Terminal Serial Number: \(deviceInfo?.getSerial() ?? "")"
        case 1:
            text = "Terminal state: \(deviceInfo?.getTerminalState() ?? "")"
        case 2:
            text = "Battery state: \(deviceInfo?.getBatteryState()?.description ?? "")"
        case 3:
            text = "SVPP version: \(deviceInfo?.getSvppFirmware() ?? "")"
        case 4:
            text = "Non Secure FW Version: \(deviceInfo?.getNonSecureFirmwareVersion() ?? "")"
        case 5:
            text = "Terminal Part Number: \(deviceInfo?.getPartNumber() ?? "")"
        case 6:
            text = "OS Version: \(deviceInfo?.getOsVersion() ?? "")"
        case 7:
            text = "Automatic power off time out: \(deviceInfo?.getAutoPowerOffTimeout()?.description ?? "")"
        case 8:
            text = "EMV ICC Config Version: \(deviceInfo?.getIccEmvConfigVersion() ?? "")"
        case 9:
            text = "EMV NFC Config Version: \(deviceInfo?.getNfcEmvConfigVersion() ?? "")"
        case 10:
            if let supportedLocaleList = deviceInfo?.getSupportedLocaleList() {
                text = "Supported locale list :"
                for locale in supportedLocaleList {
                    text += locale
                    text += ", "
                }
            }
        case 11:
            text = "Merchant Locale : \(deviceInfo?.getMerchantLocale() ?? "")"
        case 12:
            if(deviceInfo?.getChargingStatus() == nil) {
                text = "unknown"
            }else {
                switch deviceInfo?.getChargingStatus() {
                case 0x00:
                    text = "Battery State : battery is NOT charging"
                case 0x01:
                    text = "Battery State : battery is charging"
                case 0x03:
                    text = "Battery State : battery is full and dongle is plugged to the USB."
                default:
                    text = "Battery State : unknown"
                }
            }
        case 13:
            text = "Resources file version : \(deviceInfo?.getResourcesFileVersion() ?? "")"
        case 14:
            if(deviceInfo?.getSpeedMode() == nil) {
                text = "Speed Mode unknown"
            }else {
                switch deviceInfo?.getSpeedMode() {
                case 0:
                    text = "SLOW MODE"
                case 1:
                    text = "QUICK MODE"
                default:
                    text = "Speed Mode unknown"
                }
            }
        case 15:
            text = "Build configuration : \(deviceInfo?.getBuildConfiguration() ?? "Unknown")"
        case 16:
            text = "BLE version : \(deviceInfo?.getBleFirmwareVersion() ?? "")"
        default:
            text = ""
        }
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = text
        return cell
    }
}
