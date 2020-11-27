//
//  DeviceListController.swift
//  uCubeSampleApp
//
//  Created by Rémi Hillairet on 5/21/20.
//  Copyright © 2020 YouTransactor. All rights reserved.
//

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
