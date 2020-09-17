//
//  UpdateTableViewController.swift
//  uCubeSampleApp
//
//  Created by Rémi Hillairet on 7/30/20.
//  Copyright © 2020 YouTransactor. All rights reserved.
//

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
//        presentAlert(message: "Coming soon", actions: [
//            AlertAction(title: "OK")
//        ])
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
