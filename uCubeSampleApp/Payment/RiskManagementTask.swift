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

class RiskManagementTask: RiskManagementTasking {
    
    private let presenter: AlertPresenter
    private var tvr = Data([0, 0, 0, 0, 0])
    private var paymentContext: PaymentContext?
    private var monitor: TaskMonitoring?
    
    init(presenter: AlertPresenter) {
        self.presenter = presenter
    }
    
    func getTVR() -> Data {
        return tvr
    }
    
    func getContext() -> PaymentContext? {
        return paymentContext
    }
    
    func setContext(_ context: PaymentContext) {
        self.paymentContext = context
    }
    
    func execute(monitor: TaskMonitoring) {
        self.monitor = monitor
        
        presenter.presentAlert(title: "Risk management", message: "Is card stolen?", actions: [
            AlertAction(title: "Yes", handler: {
                self.end(tvr: Data([0, 0b10000, 0, 0, 0]))
            }),
            AlertAction(title: "No", handler: {
                self.end(tvr: Data([0, 0, 0, 0, 0]))
            })
        ])
    }
    
    
    public func cancel(completion: (Bool) -> Void) {
        LogManager.debug(message: "risk management Task cancellation!")
        
        //TODO: clean your risk management process's context
        monitor?.eventHandler(.cancelled, [])
        completion(true)
    }
    
    private func end(tvr: Data) {
        self.tvr = tvr
        
        if
            let selectedApplication = paymentContext?.selectedApplication,
            let selectedAid = selectedApplication.getAid()?.hexString.prefix(10)
        {
            switch selectedAid {
            case "A000000003":
                paymentContext?.applicationVersion = 140
            case "A000000004":
                paymentContext?.applicationVersion = 202
            case "A000000042":
                paymentContext?.applicationVersion = 203
            default:
                break
            }
        }
        self.monitor?.eventHandler(.success, [])
    }
    
}
