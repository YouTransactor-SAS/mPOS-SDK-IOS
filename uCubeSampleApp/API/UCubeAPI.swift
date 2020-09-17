//
//  UCubeAPI.swift
//  uCube
//
//  Created by Rémi Hillairet on 5/21/20.
//  Copyright © 2020 YouTransactor. All rights reserved.
//

public struct UCubeAPI {
    
    public typealias ProgressClosure = ((_ state: ServiceState) -> Void)
    public typealias FinishClosure = ((_ success: Bool, _ parameters: [Any]?) -> Void)
    public typealias PaymentProgressClosure = ((_ state: PaymentState, _ context: PaymentContext) -> Void)
    public typealias PaymentFinishClosure = ((_ success: Bool, _ context: PaymentContext) -> Void)
    
    public static func setupLogger(_ logger: Loggable) {
        LogManager.debug(message: "Setup log manager")
        LogManager.logger = logger
    }
    
    public static func setConnexionManager(_ connexionManager: ConnectionManager) {
        LogManager.debug(message: "Setup connexion manager")
        RPCManager.shared.connectionManager = connexionManager
    }
    
    public static func pay(request: UCubePaymentRequest, didProgress: PaymentProgressClosure? = nil, didFinish: @escaping PaymentFinishClosure) {
        LogManager.debug(message: "Start pay")
        
        let paymentContext = PaymentContext()
        paymentContext.displayResult = request.displayResult
        paymentContext.getSystemFailureInfoL1 = request.systemFailureInfo
        paymentContext.getSystemFailureInfoL2 = request.systemFailureInfo2
        paymentContext.setAmount(request.amount)
        paymentContext.currency = request.currency
        paymentContext.transactionType = request.transactionType
        paymentContext.transactionDate = request.transactionDate
        paymentContext.preferredLanguages = request.preferredLanguages
        paymentContext.setForceAuthorization(request.forceAuthorization)
        paymentContext.forceOnlinePIN = request.forceOnlinePIN
        paymentContext.requestedAuthorizationTags = request.requestedAuthorizationTags
        paymentContext.requestedSecuredTags = request.requestedSecuredTags
        paymentContext.requestedPlainTags = request.requestedPlainTags
        paymentContext.messages = request.messages
        paymentContext.alternativeMessages = request.alternativeMessages
        
        let activatedReaders = request.readers.map({ $0.code })
        
        var service: PaymentService!
        if activatedReaders.contains(RPC.Reader.nfc) || activatedReaders.count > 1 {
            service = SingleEntryPointPaymentService(context: paymentContext, enabledReaders: Data(activatedReaders))
        } else {
            service = PaymentService(context: paymentContext, enabledReaders: Data(activatedReaders))
        }
        
        service.setCardWaitTimeout(30)
        service.execute(monitor: TaskMonitor(eventHandler: { (event, parameters) in
            switch event {
            case .progress:
                didProgress?((parameters[0] as? PaymentState) ?? .unknown, paymentContext)
            case .success:
                didFinish(true, paymentContext)
            case .cancelled, .failed:
                didFinish(false, paymentContext)
            }
        }))
    }
    
    // MARK: MDM
    
    public static func isMdmManagerReady() -> Bool {
        return MDMManager.shared.isReady
    }
    
    public static func mdmRegister(didProgress: ProgressClosure? = nil, didFinish: FinishClosure? = nil) {
        LogManager.debug(message: "MDM Register")
        let service = RegisterService()
        service.execute(monitor: TaskMonitor(eventHandler: { (event: TaskEvent, parameters: [Any]) in
            switch event {
            case .progress:
                guard let state = parameters[0] as? ServiceState else {
                    LogManager.error(message: "No service state found in monitor parameters")
                    return
                }
                didProgress?(state)
            case .failed, .cancelled:
                didFinish?(false, nil)
            case .success:
                didFinish?(true, parameters)
            }
        }))
    }
    
    public static func mdmUnregister(allDevices: Bool = false) {
        if allDevices {
            MDMManager.shared.removeAllCertificates()
        } else {
            MDMManager.shared.removeCertificate()
        }
    }
    
    public static func mdmGetConfig(didProgress: ProgressClosure? = nil, didFinish: FinishClosure? = nil) {
        LogManager.debug(message: "MDM Get Config")
        let service = GetConfigService()
        service.execute(monitor: TaskMonitor(eventHandler: { (event: TaskEvent, parameters: [Any]) in
            switch event {
            case .progress:
                guard let state = parameters[0] as? ServiceState else {
                    LogManager.error(message: "No service state found in monitor parameters")
                    return
                }
                didProgress?(state)
            case .failed, .cancelled:
                didFinish?(false, nil)
            case .success:
                didFinish?(true, [service.configList])
            }
        }))
    }
    
    public static func mdmCheckUpdate(forceUpdate: Bool,
                                      checkOnlyFirmwareVersion: Bool,
                                      didProgress: ProgressClosure? = nil,
                                      didFinish: FinishClosure? = nil)
    {
        LogManager.debug(message: "MDM Check update: forceUpdate(\(forceUpdate)), checkOnlyFirmwareVersion(\(checkOnlyFirmwareVersion))")
        let service = CheckUpdateService()
        service.setForceUpdate(forceUpdate)
        service.setCheckOnlyFirmware(checkOnlyFirmwareVersion)
        service.execute(monitor: TaskMonitor(eventHandler: { (event, parameters) in
            switch event {
            case .progress:
                guard let state = parameters[0] as? ServiceState else {
                    LogManager.error(message: "No service state found in monitor parameters")
                    return
                }
                didProgress?(state)
            case .failed, .cancelled:
                didFinish?(false, nil)
            case .success:
                didFinish?(true, [service.updates, service.configs])
            }
        }))
    }
    
    public static func mdmUpdate(didProgess: ProgressClosure? = nil, didFinish: FinishClosure? = nil) {
        
    }
    
    public static func mdmSendLogs(didProgress: ProgressClosure? = nil, didFinish: FinishClosure? = nil) {
        LogManager.debug(message: "MDM Send Logs")
        let service = SendLogsService()
        service.execute(monitor: TaskMonitor(eventHandler: { (event: TaskEvent, parameters: [Any]) in
            switch event {
            case .progress:
                guard let state = parameters[0] as? ServiceState else {
                    LogManager.error(message: "No service state found in monitor parameters")
                    return
                }
                didProgress?(state)
            case .failed, .cancelled:
                didFinish?(false, nil)
            case .success:
                didFinish?(true, nil)
            }
        }))
    }
}
