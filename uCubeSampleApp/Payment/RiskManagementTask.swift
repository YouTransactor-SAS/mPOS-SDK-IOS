//
//  RiskManagementTask.swift
//  uCubeSampleApp
//
//  Created by Rémi Hillairet on 7/23/20.
//  Copyright © 2020 YouTransactor. All rights reserved.
//

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
