//
//  ConfigTableViewController.swift
//  uCubeSampleApp
//
//  Created by Rémi Hillairet on 7/30/20.
//  Copyright © 2020 YouTransactor. All rights reserved.
//

import UIKit
import UCube

class ConfigTableViewController: AlertPresenterTableViewController {
    
    private var configs: [Config] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        UCubeAPI.mdmGetConfig(didProgress: { (state: ServiceState) in
            self.presentAlert(message: "\(state.name)...", actions: [
                AlertAction(title: "OK")
            ])
        }) { (success, parameters) in
            self.dismissAlert()
            if let configs = parameters?[0] as? [Config] {
                self.configs = configs
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return configs.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return configs[section].label
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConfigCell")!
        let config = configs[indexPath.section]
        if indexPath.row == 0 {
            cell.textLabel?.text = "Minimum version: \(config.minVersion ?? "nil")"
        } else {
            cell.textLabel?.text = "Current version: \(config.currentVersion ?? "nil")"
        }
        return cell
    }

}
