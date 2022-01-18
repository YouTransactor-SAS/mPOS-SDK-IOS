//
//  DeviceInfoTableViewController.swift
//  uCubeSampleApp
//
//  Created by Rémi Hillairet on 7/17/20.
//  Copyright © 2020 YouTransactor. All rights reserved.
//

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
            RPC.Tag.speedMode
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
        return 15
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
            text = "Terminal Part Number: \(deviceInfo?.getPartNumber() ?? "")"
        case 5:
            text = "OS Version: \(deviceInfo?.getOsVersion() ?? "")"
        case 6:
            text = "Automatic power off time out: \(deviceInfo?.getAutoPowerOffTimeout()?.description ?? "")"
        case 7:
            text = "EMV ICC Config Version: \(deviceInfo?.getIccEmvConfigVersion() ?? "")"
        case 8:
            text = "EMV NFC Config Version: \(deviceInfo?.getNfcEmvConfigVersion() ?? "")"
        case 9:
            if let supportedLocaleList = deviceInfo?.getSupportedLocaleList() {
                text = "Supported locale list :"
                for locale in supportedLocaleList {
                    text += locale
                    text += ", "
                }
            }
        case 10:
            text = "Merchant Locale : \(deviceInfo?.getMerchantLocale() ?? "")"
        case 11:
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
        case 12:
            text = "BLE version : \(deviceInfo?.getBleFirmwareVersion() ?? "")"
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
        default:
            text = ""
        }
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = text
        return cell
    }
}
