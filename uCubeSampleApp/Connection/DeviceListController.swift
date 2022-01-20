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

class DeviceListController: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scanButton: UIButton!
    
    var discoveredDevices: [UCubeDevice] = []
    
    private var isScanning = false

    override func viewDidLoad() {
        super.viewDidLoad()
        startScan()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopScan()
        BLEConnectionManager.shared.scanDelegate = nil
    }
    
    private func stopActivityAnimation() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
        }
    }
    
    private func startScan() {
        scanButton.setTitle("STOP", for: .normal)
        discoveredDevices.removeAll()
        BLEConnectionManager.shared.scanDelegate = self
        BLEConnectionManager.shared.startScan()
        activityIndicator.startAnimating()
        isScanning = true
    }
    
    private func stopScan() {
        scanButton.setTitle("START", for: .normal)
        BLEConnectionManager.shared.stopScan()
        isScanning = false
    }
    
    @IBAction func toggleScanAction(_ sender: Any) {
        if isScanning {
            stopScan()
        } else {
            startScan()
        }
    }
}

extension DeviceListController: ScanDelegate {
    
    func scanDidDiscoverDevice(_ device: UCubeDevice) {
        LogManager.debug(message: "Did discover \(device)")
        discoveredDevices.append(device)
        tableView.reloadData()
    }
    
    func scanDidComplete(with devices: [UCubeDevice]) {
        LogManager.debug(message: "Scan did complete with \(devices)")
        stopScan()
        stopActivityAnimation()
    }
    
    func scanDidFail(with error: UCubeBluetoothError) {
        LogManager.debug(message: "Scan did fail with error \(error)")
        stopScan()
        stopActivityAnimation()
    }
}

extension DeviceListController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return discoveredDevices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceCell") as! DeviceTableViewCell
        let discoveredDevice = discoveredDevices[indexPath.row]
        cell.nameLabel.text = "\(discoveredDevice.name)"
        cell.identifierLabel.text = discoveredDevice.identifier.uuidString
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        (navigationController?.viewControllers[0] as? MainViewController)?.device = discoveredDevices[indexPath.row]
        navigationController?.popViewController(animated: true)
    }
}
