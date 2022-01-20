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
