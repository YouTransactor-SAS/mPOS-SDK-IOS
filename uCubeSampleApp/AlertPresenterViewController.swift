//
//  AlertPresenterViewController.swift
//  uCubeSampleApp
//
//  Created by Rémi Hillairet on 8/5/20.
//  Copyright © 2020 YouTransactor. All rights reserved.
//

import UIKit

protocol AlertPresenter {
    func presentAlert(title: String?, message: String?, actions: [AlertAction]?)
    func dismissAlert(completion: (() -> Void)?)
}

class AlertPresenterTableViewController: UITableViewController, AlertPresenter {
    
    let alert = AlertViewController.initWithStoryboard()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func presentAlert(title: String? = nil, message: String? = nil, actions: [AlertAction]? = nil) {
        alert.update(title: title, message: message, actions: actions)
        if alert.presentingViewController == nil {
            present(alert, animated: false)
        }
    }
    
    func dismissAlert(completion innerCompletion: (() -> Void)? = nil) {
        alert.dismiss(animated: false, completion: {
            innerCompletion?()
        })
    }
}

class AlertPresenterViewController: UIViewController, AlertPresenter {
    
    let alert = AlertViewController.initWithStoryboard()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func presentAlert(title: String? = nil, message: String? = nil, actions: [AlertAction]? = nil) {
        alert.update(title: title, message: message, actions: actions)
        if alert.presentingViewController == nil {
            present(alert, animated: false)
        }
    }
    
    func dismissAlert(completion innerCompletion: (() -> Void)? = nil) {
        alert.dismiss(animated: false, completion: {
            innerCompletion?()
        })
    }
}
