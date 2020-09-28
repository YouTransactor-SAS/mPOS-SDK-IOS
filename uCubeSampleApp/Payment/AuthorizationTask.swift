//
//  AuthorizationTask.swift
//  uCubeSampleApp
//
//  Created by Rémi Hillairet on 7/23/20.
//  Copyright © 2020 YouTransactor. All rights reserved.
//

import UCube
import UIKit

class AuthorizationTask: AuthorizationTasking {
    
    private let presenter: AlertPresenter
    private var authorizationResponse = Data([0x8A, 0x02, 0x30, 0x30]) // Approved
    private var monitor: TaskMonitoring?
    private var paymentContext: PaymentContext?
    
    init(presenter: AlertPresenter) {
        self.presenter = presenter
    }
    
    func getAuthorizationResponse() -> Data {
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
        
        //TODO: send these tags to the server
        //TODO: call server to do the authorization
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
            AlertAction(title: "Declined", handler: {
                self.end(choice: 1)
            }),
            AlertAction(title: "Unable to go online", handler: {
                self.end(choice: 2)
            })
        ])
    }
    
    private func end(choice: Int) {
        switch choice {
        case 0:
            authorizationResponse = Data([0x8A, 0x02, 0x30, 0x30])
        case 1:
            authorizationResponse = Data([0x8A, 0x02, 0x30, 0x35])
        case 2:
            authorizationResponse = Data([0x8A, 0x02, 0x39, 0x38])
        default:
            break
        }
        monitor?.eventHandler(.success, [])
    }
}
