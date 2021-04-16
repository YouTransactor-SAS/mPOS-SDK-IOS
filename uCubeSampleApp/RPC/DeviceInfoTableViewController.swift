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
            RPC.Tag.configurationMerchantInterfaceLocale
        ]
        let uInt8Tags = tags.map{ UInt8($0) }
        let command = GetInfoCommand(tags: uInt8Tags)
        command.execute(monitor: TaskMonitor(eventHandler: { (event: TaskEvent, parameters: [Any]) in
            switch event {
            case .failed, .cancelled:
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
        return 11
    }
    
    private func getNfcModuleText(_ state: UInt8) -> String {
        var nfcModuleState = ""
        switch state {
        case 0x00:
            nfcModuleState = "no mpos module available"
        case 0x01:
            nfcModuleState = "mpos module initializing"
        case 0x02:
            nfcModuleState = "mpos initialization done"
        case 0x03:
            nfcModuleState = "mpos module is ready"
        case 0x04:
            nfcModuleState = "mpos module is in bootloader mode"
        case 0x05:
            nfcModuleState = "mpos bootloader initializing"
        case 0x06:
            nfcModuleState = "mpos module faces an internal error"
        case 0x07:
            nfcModuleState = "mpos module firmware not loaded"
        case 0x08:
            nfcModuleState = "mpos firmware update is ongoing"
        case 0x09:
            nfcModuleState = "mpos app firmware is corrupted"
        case 0x10:
            nfcModuleState = "mpos bootloader firmware is corrupted"
        default:
            break
        }
        return nfcModuleState
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
                    text += locale.identifier
                    text += ", "
                }
            }
        case 10:
            text = "Merchant Locale : \(deviceInfo?.getMerchantLocale()?.identifier ?? "")"
        default:
            text = ""
        }
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = text
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
