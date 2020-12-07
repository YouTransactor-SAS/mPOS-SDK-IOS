//
//  RiskManagementTask.swift
//  uCubeSampleApp
//
//  Created by Rémi Hillairet on 7/23/20.
//  Copyright © 2020 YouTransactor. All rights reserved.
//

import UIKit
import UCube

class UserCardHolderLanguageTask: UseCardHolderLanguageTasking {
   
    static let en: String = "656E"
    static let fr: String = "6672"
    
    static let enMessages:[PaymentMessages:String] = [
        
        PaymentMessages.LBL_prepare_context: "preparing context",
        PaymentMessages.LBL_authorization: "Authorization processing",
        PaymentMessages.LBL_smc_initialization: "initialization processing",
        PaymentMessages.LBL_smc_risk_management: "risque management processing",
        PaymentMessages.LBL_smc_finalization: "finalization processing",
        PaymentMessages.LBL_smc_remove_card: "remove card, please",
        
        PaymentMessages.LBL_nfc_complete: "complete processing",
        PaymentMessages.LBL_wait_online_pin_process: "online pin processing",
        PaymentMessages.LBL_pin_request: "enter pin",
        
        PaymentMessages.LBL_approved: "Approved",
        PaymentMessages.LBL_declined: "Declined",
        PaymentMessages.LBL_unsupported_card: "Unsupported card",
        PaymentMessages.LBL_cancelled: "Cancelled",
        PaymentMessages.LBL_error: "Error",
        PaymentMessages.LBL_no_card_detected: "No card detected",
        PaymentMessages.LBL_wrong_activated_reader: "wrong activated reader",
        
        PaymentMessages.LBL_try_other_interface: "try other interface",
        PaymentMessages.LBL_end_application: "end application ",
        PaymentMessages.LBL_failed: "failed",
        PaymentMessages.LBL_wrong_nfc_outcome: "wrong nfc outcome",
    
        PaymentMessages.LBL_wrong_cryptogram_value: "wrong cryptogram value",
        PaymentMessages.LBL_missing_required_cryptogram: "missing required cryptogram",
        
        PaymentMessages.GLOBAL_LBL_xposition: "00",
        PaymentMessages.GLOBAL_LBL_yposition: "0C",
        PaymentMessages.GLOBAL_LBL_font_id: "00",
    ]
    
    static let frMessages:[PaymentMessages:String] = [
        
        PaymentMessages.LBL_prepare_context: "preparation du context",
        PaymentMessages.LBL_authorization: "Authorization en cours",
        PaymentMessages.LBL_smc_initialization: "initialisation en cours",
        PaymentMessages.LBL_smc_risk_management: "gestion du risque en cours",
        PaymentMessages.LBL_smc_finalization: "finalisation en cours",
        PaymentMessages.LBL_smc_remove_card: "enlevez la carte, svp",
        
        PaymentMessages.LBL_nfc_complete: "finalisation en cours",
        PaymentMessages.LBL_wait_online_pin_process: "pin online en cours",
        PaymentMessages.LBL_pin_request: "saisir votre pin",
        
        PaymentMessages.LBL_approved: "Approve",
        PaymentMessages.LBL_declined: "Decline",
        PaymentMessages.LBL_unsupported_card: "carte non supporte",
        PaymentMessages.LBL_cancelled: "Annule",
        PaymentMessages.LBL_error: "Erreur",
        PaymentMessages.LBL_no_card_detected: "Carte non detecte",
        PaymentMessages.LBL_wrong_activated_reader: "mauvaise interface active",
        
        PaymentMessages.LBL_try_other_interface: "Utilisez une autre interface",
        PaymentMessages.LBL_end_application: "Fin de l'application ",
        PaymentMessages.LBL_failed: "Echec",
        PaymentMessages.LBL_wrong_nfc_outcome: "Mauvai nfc outcome",
    
        PaymentMessages.LBL_wrong_cryptogram_value: "Mauvai cryptogramme ",
        PaymentMessages.LBL_missing_required_cryptogram: "Cryptogramme non retrouve",
        
        PaymentMessages.GLOBAL_LBL_xposition: "00",
        PaymentMessages.GLOBAL_LBL_yposition: "0C",
        PaymentMessages.GLOBAL_LBL_font_id: "00",
    ]
    
    private var paymentContext: PaymentContext?
    private var monitor: TaskMonitoring?
    private var selectedCardHolderLanguage : Data?
    
    func setSelectedCardHolderLanguage(selectedCardHolderLanguage: Data) {
        self.selectedCardHolderLanguage = selectedCardHolderLanguage
    }
    
    func getContext() -> PaymentContext? {
        return paymentContext
    }

    func setContext(_ context: PaymentContext) {
        self.paymentContext = context
    }
    
    func execute(monitor: TaskMonitoring) {
        self.monitor = monitor
        
        if(self.selectedCardHolderLanguage == nil || self.selectedCardHolderLanguage?.count ?? 0 < 2) {
            LogManager.error(message: "wrong selected card holder language value")
            self.monitor?.eventHandler(.failed, [])
            return
        }
        
        switch self.selectedCardHolderLanguage?.hexString{
        case UserCardHolderLanguageTask.en:
            LogManager.debug(message: "card holder language is EN")
            paymentContext?.messages = UserCardHolderLanguageTask.enMessages
        case UserCardHolderLanguageTask.fr:
            LogManager.debug(message: "card holder language is FR")
            paymentContext?.messages = UserCardHolderLanguageTask.frMessages
        default:
            LogManager.debug(message: "card holder language is unknown")
            break
        }
        
        self.monitor?.eventHandler(.success, [])
    }
    
    public func cancel() {
        LogManager.debug(message: "Task cancellation!")
        //TODO: clean your process's context
        monitor?.eventHandler(.cancelled, [])
    }
    
}
