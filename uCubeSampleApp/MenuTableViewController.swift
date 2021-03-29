//
//  MenuTableViewController.swift
//  uCubeSampleApp
//
//  Created by Rémi Hillairet on 7/10/20.
//  Copyright © 2020 YouTransactor. All rights reserved.
//

import CoreBluetooth
import UIKit
import UCube

class MenuTableViewController: AlertPresenterTableViewController {
    
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var mdmRegisterButton: UIButton!
    @IBOutlet weak var mdmConfigButton: UIButton!
    @IBOutlet weak var mdmUpdateButton: UIButton!
    @IBOutlet weak var mdmSendLogsButton: UIButton!
    @IBOutlet weak var mdmUnregisterButton: UIButton!
    
    private let deviceConnection = DeviceConnection()
    private let displayMessage = DisplayMessage()
    private var updates: [BinaryUpdate] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Device connection UI handlers
        deviceConnection.connectCompletion = {
            self.dismissAlert()
            self.connectButton.setTitle("DISCONNECT", for: .normal)
        }
        deviceConnection.disconnectCompletion = {
            self.dismissAlert()
            self.connectButton.setTitle("CONNECT", for: .normal)
        }
        updateMDMButtons()
        BLEConnectionManager.shared.retriveDevicesConnectedViaSystemMenu(completion: { (success: Bool, devicesConnected: [CBPeripheral]?) in
                if(!success) {
                    return
                }
                
            self.presentAlert(message: "Warning! Device \(devicesConnected?.first?.name ?? "") already connected", actions: [
                    AlertAction(title: "OK")
                ])
            })
    }
    
    func isDeviceSelected(showAlert: Bool = true) -> Bool {
        if BLEConnectionManager.shared.getDevice() == nil {
            if showAlert {
                presentAlert(message: "No device selected", actions: [
                    AlertAction(title: "OK")
                ])
            }
            return false
        }
        return true
    }
    
    func updateMDMButtons() {
        if UCubeAPI.isMdmManagerReady() {
            mdmRegisterButton.isHidden = true
            mdmConfigButton.isHidden = false
            mdmUpdateButton.isHidden = false
            mdmSendLogsButton.isHidden = false
            mdmUnregisterButton.isHidden = false
        } else {
            mdmRegisterButton.isHidden = false
            mdmConfigButton.isHidden = true
            mdmUpdateButton.isHidden = true
            mdmSendLogsButton.isHidden = true
            mdmUnregisterButton.isHidden = true
        }
    }
    
    // MARK: - IBActions
    
    /*@IBAction func connectAction(_ sender: UIButton) {
        guard isDeviceSelected() else {
            return
        }
        
        let device = BLEConnectionManager.shared.getDevice()!
        if BLEConnectionManager.shared.isConnected {
            presentAlert(title: nil, message: "Disconnecting from \(device.name)...")
            deviceConnection.disconnect()
        } else {
            presentAlert(title: nil, message: "Connecting to \(device.name)...", actions: [
                AlertAction(title: "Cancel", handler: {
                    BLEConnectionManager.shared.cancelConnect()
                })
            ])
            deviceConnection.connect()
        }
    }*/
    
   @IBAction func connectAction(_ sender: UIButton) {
        guard isDeviceSelected() else {
            return
        }

        let device = BLEConnectionManager.shared.getDevice()!
        if BLEConnectionManager.shared.isConnected {
            presentAlert(title: nil, message: "Disconnecting from \(device.name)...")
            BLEConnectionManager.shared.disconnect()
        } else {
            presentAlert(title: nil, message: "Connecting to \(device.name)...", actions: [
                AlertAction(title: "Cancel", handler: {
                    BLEConnectionManager.shared.cancelConnect()
                })
            ])

            BLEConnectionManager.shared.connect(
                identifier: device.identifier,
                completion: { _ in
                    print("BLEConnectionManager.shared.connect(completion:) called")
                }
            )
        }
    }
    
  /*  @IBAction func connectAction(_ sender: UIButton) {
        guard isDeviceSelected() else {
            return
        }

        let device = BLEConnectionManager.shared.getDevice()!
        if BLEConnectionManager.shared.isConnected {
            presentAlert(title: nil, message: "Disconnecting from \(device.name)...")
            BLEConnectionManager.shared.disconnect()
        } else {
            presentAlert(title: nil, message: "Connecting to \(device.name)...", actions: [
                AlertAction(title: "Cancel", handler: {
                    BLEConnectionManager.shared.cancelConnect()
                })
            ])

            BLEConnectionManager.shared.connect(
                identifier: device.identifier,
                completion: { _ in
                    print("BLEConnectionManager.shared.connect(completion:) called")
                }
            )
        }
    }*/
    
    @IBAction func changeLanguage(_ sender: Any) {
        guard isDeviceSelected() else {
            return
        }
        
        self.presentAlert(title: nil, message: "get Supported locale progress...")
        
        UCubeAPI.getSupportedLocaleList(didProgress: { (state: UCubeAPI.ProgressState) in
            LogManager.debug(message: "get supported locale list did progress: \(state.name)")
        }, didFinish: { (success: Bool, parameters: [Any]?) in
            if(!success || parameters == nil) {
                self.presentAlert(title: nil, message: "get supported locale list failed", actions: [
                    AlertAction(title: "OK")
                ])
            }else {
                self.dismissAlert()
                let supportedLocaleList = parameters as! [String]
                let alert = UIAlertController(title: "Choose a language", message: nil, preferredStyle: .actionSheet)
                for locale in supportedLocaleList {
                    alert.addAction(UIAlertAction(title: locale, style: .default) { _ in
                        self.setLocale(locale: locale)
                    })
                }
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    private func setLocale(locale: String) {
        self.presentAlert(title: nil, message: "set locale \(locale) progress...")
        
        UCubeAPI.setLocale(locale: locale, didProgress: { (state: UCubeAPI.ProgressState) in
            LogManager.debug(message: "set locale \(locale) did progress: \(state.name)")
        }, didFinish: { (success: Bool, parameters: [Any]?) in
            if(success) {
                self.presentAlert(title: nil, message: "set locale did finish with success", actions: [
                    AlertAction(title: "OK")
                ])
            }else {
                self.presentAlert(title: nil, message: "set locale failed", actions: [
                    AlertAction(title: "OK")
                ])
            }
        })
    }
    
    @IBAction func displayAction(_ sender: Any) {
        guard isDeviceSelected() else {
            return
        }
        displayMessage.display("Hello world") { (success: Bool, message: String?) in
            if let message = message {
                self.presentAlert(title: nil, message: message, actions: [
                    AlertAction(title: "OK")
                ])
            }
        }
    }
    
    @IBAction func mdmRegisterAction(_ sender: Any) {
        guard isDeviceSelected() else {
            return
        }
        let device = BLEConnectionManager.shared.getDevice()!
        presentAlert(title: nil, message: "Registering \(device.name)...")
        UCubeAPI.mdmRegister(didProgress: { (state: ServiceState) in
            self.presentAlert(title: nil, message: "Registering \(device.name)...")
        }) { (success, parameters: [Any]?) in
            self.dismissAlert()
            self.updateMDMButtons()
        }
    }
    
    @IBAction func mdmUpdateAction(_ sender: Any) {
        var forceUpdate = false
        var checkOnlyFirmware = false
        
        let checkOnlyFirmwareCompletion = {
            UCubeAPI.mdmCheckUpdate(forceUpdate: forceUpdate, checkOnlyFirmwareVersion: checkOnlyFirmware, didProgress: { (state: ServiceState) in
                self.presentAlert(title: nil, message: "\(state.name) progress...")
            }) { (success, parameters) in
                if success {
                    let updates = parameters![0] as! [BinaryUpdate]
//                    let configs = parameters![1] as! [Config]
                    if updates.count == 0 {
                        self.presentAlert(message: "uCube is up-to-date", actions: [
                            AlertAction(title: "OK")
                        ])
                    } else {
                        self.updates = updates
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.dismissAlert {
                                self.performSegue(withIdentifier: "UpdateSegue", sender: self)
                            }
                        }
                    }
                } else {
                    self.presentAlert(message: "Update failed", actions: [
                        AlertAction(title: "OK")
                    ])
                }
            }
        }
        
        let forceUpdateCompletion = {
            self.presentAlert(message: "Check only firmware version?", actions: [
                AlertAction(title: "NO", handler: {
                    checkOnlyFirmware = false
                    checkOnlyFirmwareCompletion()
                }),
                AlertAction(title: "YES", handler: {
                    checkOnlyFirmware = true
                    checkOnlyFirmwareCompletion()
                })
            ])
        }
        
        presentAlert(message: "Force update?\n(install same version)", actions: [
            AlertAction(title: "NO", handler: {
                forceUpdate = false
                forceUpdateCompletion()
            }, autoDismiss: false),
            AlertAction(title: "YES", handler: {
                forceUpdate = true
                forceUpdateCompletion()
            }, autoDismiss: false)
        ])
    }
    
    @IBAction func mdmSendLogs(_ sender: Any) {
        guard isDeviceSelected() else {
            return
        }
        UCubeAPI.mdmSendLogs(didProgress: { (state: ServiceState) in
            self.presentAlert(message: "\(state.name) progress...")
        }) { (success, parameters) in
            if success {
                self.presentAlert(message: "Send logs succeeded", actions: [
                    AlertAction(title: "OK")
                ])
            } else {
                self.presentAlert(message: "Send logs failed", actions: [
                    AlertAction(title: "OK")
                ])
            }
        }
    }
    
    @IBAction func mdmUnregisterAction(_ sender: Any) {
        UCubeAPI.mdmUnregister()
        self.updateMDMButtons()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let updateVC = segue.destination as? UpdateTableViewController {
            updateVC.updates = self.updates
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier != "ScanSegue" {
            return isDeviceSelected()
        }
        return true
    }
}
