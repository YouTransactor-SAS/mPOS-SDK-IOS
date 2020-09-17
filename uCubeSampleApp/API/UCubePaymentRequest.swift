//
//  UCubePaymentRequest.swift
//  uCube
//
//  Created by Rémi Hillairet on 7/22/20.
//  Copyright © 2020 YouTransactor. All rights reserved.
//

public struct UCubePaymentRequest {
    
    public static let currencyEUR = Currency(label: "EUR", code: 978, exponent: 2)
    public static let currencyUSD = Currency(label: "USD", code: 840, exponent: 2)
    
    public var amount: Double = -1
    public var currency: Currency = UCubePaymentRequest.currencyUSD
    public var transactionType: TransactionType = .purchase
    public var transactionDate: Date?
    public var cardWaitTimeout: Int = 30
    public var preferredLanguages: [String] = ["en"]
    public var systemFailureInfo: Bool = false
    public var systemFailureInfo2: Bool = false
    public var forceOnlinePIN: Bool = false // only for NFC and MSR
    public var forceAuthorization: Bool = false
    public var readers: [CardReaderType] = [.icc]
    public var displayResult: Bool = true
    public var messages: [String: String]?
    public var alternativeMessages: [String: String]?
    
    public var authorizationTask: AuthorizationTasking?
    public var riskManagementTask: RiskManagementTasking?
    public var applicationSelectionTask: ApplicationSelectionTasking?
    
    public var requestedPlainTags: [Int]?
    public var requestedSecuredTags: [Int]?
    public var requestedAuthorizationTags: [Int]?
    
    public init() {
        
    }
}
