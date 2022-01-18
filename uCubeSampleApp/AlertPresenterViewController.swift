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
