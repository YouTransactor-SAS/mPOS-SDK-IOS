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

class UpdateTableViewController: AlertPresenterTableViewController {
    
    var updates: [BinaryUpdate] = [] {
        didSet {
            selectedIndexes = (0..<updates.count).map({$0})
        }
    }
    private var selectedIndexes: [Int] = []

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let topPadding = (view.frame.height + tableView.contentOffset.y - tableView.contentSize.height) / 2
        if tableView.tableHeaderView == nil {
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: topPadding > 24 ? topPadding : 24))
            headerView.backgroundColor = .clear
            tableView.tableHeaderView = headerView
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return updates.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UpdateCell")!
        let update = updates[indexPath.row]
        cell.textLabel?.text = "\(update.config.label ?? "") \(update.config.currentVersion ?? "") \(update.mandatory ? "(Mandatory)" : "")"
        cell.accessoryType = selectedIndexes.contains(indexPath.row) ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }
        if selectedIndexes.contains(indexPath.row) {
            selectedIndexes.removeAll(where: { $0 == indexPath.row })
        } else {
            selectedIndexes.append(indexPath.row)
        }
        cell.accessoryType = selectedIndexes.contains(indexPath.row) ? .checkmark : .none
        tableView.deselectRow(at: indexPath, animated: true)
    }

    @IBAction func updateAction(_ sender: Any) {
        var selectedUpdates: [BinaryUpdate] = []
        for i in 0..<updates.count {
            if selectedIndexes.contains(i) {
                selectedUpdates.append(updates[i])
            }
        }

        UCubeAPI.mdmUpdate(updates: selectedUpdates, didProgess: { state in
            self.presentAlert(message: "\(state.name)...")
        }) { (success, parameters) in
            if success {
                self.presentAlert(message: "Update succeeded", actions: [
                    AlertAction(title: "OK")
                ])
            } else {
                self.presentAlert(message: "Update failed", actions: [
                    AlertAction(title: "OK")
                ])
            }
        }
    }
}
