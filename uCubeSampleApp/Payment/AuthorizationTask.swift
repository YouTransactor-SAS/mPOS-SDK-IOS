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

import UCube
import UIKit

class AuthorizationTask: AuthorizationTasking {
    
    private let presenter: AlertPresenter
    private var authorizationResponse : Data?
    private var monitor: TaskMonitoring?
    private var paymentContext: PaymentContext?
    
    init(presenter: AlertPresenter) {
        self.presenter = presenter
    }
    
    func getAuthorizationResponse() -> Data? {
        return authorizationResponse
    }
    
    func getContext() -> PaymentContext? {
        return paymentContext
    }
    
    func setContext(_ context: PaymentContext) {
        self.paymentContext = context
    }
    
    func execute(monitor: TaskMonitoring) {
        self.monitor = monitor
        
        if(self.paymentContext?.authorizationPlainTagsValues == nil){
            monitor.eventHandler(.failed, [])
            return
        }
            
        //TODO: send these tags to the server
        //TODO: call server to do the authorization
        //TODO: send self.paymentContext?.authorizationGetPlainTagsResponse
        if let plainTagTLV = self.paymentContext?.authorizationPlainTagsValues {
           for (tag, value) in plainTagTLV {
               LogManager.debug(message: "Plain tag: 0x\(tag.hexString), \(tag) = 0x\(value.hexString)")
           }
        }
        
        if let securedTagBlock = self.paymentContext?.authorizationSecuredTagsValues {
           LogManager.debug(message: "secured tag block: \(securedTagBlock.hexString)")
        }

        presenter.presentAlert(title: "Authorization response", message: nil, actions: [
            AlertAction(title: "Approved", handler: {
                self.end(choice: 0)
            }),
            AlertAction(title: "SCA (0x1A)", handler: {
                self.end(choice: 1)
            }),
            AlertAction(title: "SCA (0x70)", handler: {
                self.end(choice: 2)
            }),
            AlertAction(title: "Declined", handler: {
                self.end(choice: 3)
            }),
            AlertAction(title: "Unable to go online", handler: {
                self.end(choice: 4)
            })
        ])
    }
    
    public func cancel(completion: (Bool) -> Void) {
        LogManager.debug(message: "Authorization Task cancellation!")
        
        //TODO: clean your authorization process's context
        presenter.dismissAlert {}
        
        self.monitor?.eventHandler(.cancelled, [])
        completion(true)
    }
    
    private func end(choice: Int) {
        switch choice {
        case 0:
            authorizationResponse = Data([0x8A, 0x02, 0x30, 0x30])
        case 1:
            authorizationResponse = Data([0x8A, 0x02, 0x31, 0x41])
        case 2:
            authorizationResponse = Data([0x8A, 0x02, 0x37, 0x30, 0xDF, 0x76, 0x01, 0x01])
        case 3:
            authorizationResponse = Data([0x8A, 0x02, 0x30, 0x35])
        case 4:
            authorizationResponse = Data([0x8A, 0x02, 0x39, 0x38])
        default:
            break
        }
        monitor?.eventHandler(.success, [])
    }
}
