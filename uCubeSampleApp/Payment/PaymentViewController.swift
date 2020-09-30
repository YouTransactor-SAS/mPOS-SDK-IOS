//
//  PaymentViewController.swift
//  uCubeSampleApp
//
//  Created by Rémi Hillairet on 7/29/20.
//  Copyright © 2020 YouTransactor. All rights reserved.
//

import UIKit
import UCube

class PaymentViewController: AlertPresenterTableViewController {

    @IBOutlet weak var cardWaitTimeoutTextField: UITextField!
    @IBOutlet weak var transactionTypeLabel: UILabel!
    @IBOutlet weak var enterAmountOnCubeSwitch: UISwitch!
    @IBOutlet weak var contactOnlySwitch: UISwitch!
    @IBOutlet weak var forceAuthorizationSwitch: UISwitch!
    @IBOutlet weak var forceOnlinePinSwitch: UISwitch!
    @IBOutlet weak var displayResultOnCubeSwitch: UISwitch!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var paymentResultLabel: UILabel!
    
    private var transactionType: TransactionType = .purchase
    private var currency: Currency = UCubePaymentRequest.currencyEUR
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapView)))
        enterAmountOnCubeSwitch.isEnabled = false
        paymentResultLabel.isHidden = true
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
    
    @objc
    func didTapView() {
        cardWaitTimeoutTextField.resignFirstResponder()
        amountTextField.resignFirstResponder()
    }
    
    @IBAction func startPayment(_ sender: Any) {
        guard
            let cardWaitTimeoutText = cardWaitTimeoutTextField.text,
            let cardWaitTimeout = Int(cardWaitTimeoutText),
            let amountText = amountTextField.text,
            let amount = UInt64(amountText.replacingOccurrences(of: ".", with: ""))
            else {
                return
        }
        
        var paymentRequest = UCubePaymentRequest()
        paymentRequest.displayResult = displayResultOnCubeSwitch.isOn
        paymentRequest.cardWaitTimeout = cardWaitTimeout
        paymentRequest.systemFailureInfo = true
        paymentRequest.systemFailureInfo2 = true
        if !enterAmountOnCubeSwitch.isOn {
            paymentRequest.amount = UInt64(amount)
        }
        paymentRequest.currency = currency
        paymentRequest.transactionType = transactionType
        paymentRequest.transactionDate = Date()
        paymentRequest.preferredLanguages = ["en"]
        paymentRequest.forceAuthorization = forceAuthorizationSwitch.isOn
        paymentRequest.forceOnlinePIN = forceOnlinePinSwitch.isOn
        paymentRequest.authorizationPlainTags = [
            RPC.EMVTag.TAG_4F_APPLICATION_IDENTIFIER,
            RPC.EMVTag.TAG_50_APPLICATION_LABEL,
            RPC.EMVTag.TAG_5F2A_TRANSACTION_CURRENCY_CODE,
            RPC.EMVTag.TAG_5F34_APPLICATION_PRIMARY_ACCOUNT_NUMBER_SEQUENCE_NUMBER,
            RPC.EMVTag.TAG_81_AMOUNT_AUTHORISED,
            RPC.EMVTag.TAG_8E_CARDHOLDER_VERIFICATION_METHOD_LIST,
            RPC.EMVTag.TAG_95_TERMINAL_VERIFICATION_RESULTS,
            RPC.EMVTag.TAG_9B_TRANSACTION_STATUS_INFORMATION,
            RPC.EMVTag.TAG_99_TRANSACTION_PERSONAL_IDENTIFICATION_NUMBER_DATA,
            RPC.EMVTag.TAG_9A_TRANSACTION_DATE,
            RPC.EMVTag.TAG_9F1A_TERMINAL_COUNTRY_CODE,
            RPC.EMVTag.TAG_DF37_SELECTED_CARDHOLDER_LANGUAGE
        ]
        
        paymentRequest.authorizationSecuredTags = [
            RPC.EMVTag.TAG_SECURE_5A_APPLICATION_PRIMARY_ACCOUNT_NUMBER,
            RPC.EMVTag.TAG_SECURE_57_TRACK_2_EQUIVALENT_DATA,
            RPC.EMVTag.TAG_SECURE_56_TRACK_1_DATA,
            RPC.EMVTag.TAG_SECURE_5F20_CARDHOLDER_NAME,
            RPC.EMVTag.TAG_SECURE_5F24_APPLICATION_EXPIRATION_DATE,
            RPC.EMVTag.TAG_SECURE_5F30_SERVICE_CODE,
            RPC.EMVTag.TAG_SECURE_9F0B_CARDHOLDER_NAME_EXTENDED,
            RPC.EMVTag.TAG_SECURE_9F6B_TRACK_2_DATA
        ]
        
        paymentRequest.finalizationPlainTags = [
            RPC.EMVTag.TAG_95_TERMINAL_VERIFICATION_RESULTS,
            RPC.EMVTag.TAG_4F_APPLICATION_IDENTIFIER,
            RPC.EMVTag.TAG_50_APPLICATION_LABEL,
            RPC.EMVTag.TAG_5F2A_TRANSACTION_CURRENCY_CODE,
            RPC.EMVTag.TAG_5F34_APPLICATION_PRIMARY_ACCOUNT_NUMBER_SEQUENCE_NUMBER,
            RPC.EMVTag.TAG_81_AMOUNT_AUTHORISED,
            RPC.EMVTag.TAG_8E_CARDHOLDER_VERIFICATION_METHOD_LIST,
            RPC.EMVTag.TAG_95_TERMINAL_VERIFICATION_RESULTS,
            RPC.EMVTag.TAG_9B_TRANSACTION_STATUS_INFORMATION,
            RPC.EMVTag.TAG_99_TRANSACTION_PERSONAL_IDENTIFICATION_NUMBER_DATA,
            RPC.EMVTag.TAG_9A_TRANSACTION_DATE,
            RPC.EMVTag.TAG_9F1A_TERMINAL_COUNTRY_CODE,
            RPC.EMVTag.TAG_DF37_SELECTED_CARDHOLDER_LANGUAGE,
        ]
        
        paymentRequest.finalizationSecuredTags = [
            RPC.EMVTag.TAG_SECURE_5A_APPLICATION_PRIMARY_ACCOUNT_NUMBER,
            RPC.EMVTag.TAG_SECURE_57_TRACK_2_EQUIVALENT_DATA,
            RPC.EMVTag.TAG_SECURE_56_TRACK_1_DATA,
            RPC.EMVTag.TAG_SECURE_5F20_CARDHOLDER_NAME,
            RPC.EMVTag.TAG_SECURE_5F24_APPLICATION_EXPIRATION_DATE,
            RPC.EMVTag.TAG_SECURE_5F30_SERVICE_CODE,
            RPC.EMVTag.TAG_SECURE_9F0B_CARDHOLDER_NAME_EXTENDED,
            RPC.EMVTag.TAG_SECURE_9F6B_TRACK_2_DATA
        ]
        
        if (!contactOnlySwitch.isOn) {
            paymentRequest.readers.append(.nfc)
        }
        
        paymentRequest.riskManagementTask = RiskManagementTask(presenter: self)
        paymentRequest.authorizationTask = AuthorizationTask(presenter: self)
        
        let messages:[PaymentMessages:String] = [
             PaymentMessages.LBL_wait_context_reset: "Please wait",
             PaymentMessages.LBL_wait_transaction_finalization: "Please wait",
             PaymentMessages.LBL_wait_online_pin_process: "Please wait",
             PaymentMessages.LBL_wait_open_new_secure_session: "Please wait",
             PaymentMessages.LBL_wait_payment_service_initialization: "Please wait",
             PaymentMessages.LBL_authorization: "Authorization processing",
             PaymentMessages.LBL_remove_card: "Remove card",
             PaymentMessages.LBL_approved: "Approved",
             PaymentMessages.LBL_declined: "Declined",
             PaymentMessages.LBL_use_chip: "Use chip",
             PaymentMessages.LBL_no_card_detected: "No card detected",
             PaymentMessages.LBL_unsupported_card: "Unsupported card",
             PaymentMessages.LBL_refused_card: "Card refused",
             PaymentMessages.LBL_cancelled: "Cancelled",
             PaymentMessages.LBL_try_other_interface: "Try other interface",
             PaymentMessages.LBL_configuration_error: "Config Error",
             PaymentMessages.LBL_wait_card: "%@ %d\nInsert card",
             PaymentMessages.LBL_wait_cancel: "Cancellation \n Please wait",
             PaymentMessages.GLOBAL_LBL_xposition: "00",
             PaymentMessages.GLOBAL_LBL_yposition: "0C",
             PaymentMessages.GLOBAL_LBL_font_id: "00",
        ]

        paymentRequest.messages = messages
        
        paymentResultLabel.isHidden = true
            var paymentService : PaymentService?
            paymentService = UCubeAPI.pay(request: paymentRequest, didProgress: { (state: PaymentState, context: PaymentContext) in
            LogManager.debug(message: "Payment did progress: \(state.name)")
            
            var message = ""
            switch state {
            case .cancelAll, .getInfo:
                message = "Prepare payment..."
            case .waitCard:
                message = "Waiting for card insertion..."
            case .enterSecureSession, .ksnAvailable:
                message = "Please wait..."
            case .smcBuildCandidateList, .smcSelectApplication, .smcUserSelectApplication:
                message = "App selection..."
            case .smcInitTransaction, .startNFCTransaction:
                message = "Starting..., please wait"
            case .smcRiskManagement:
                message = "Risk management processing..."
            case .smcProcessTransaction, .smcGetAuthorizationPlainTags, .smcGetAuthorizationSecuredTags, .msrGetPlainTags, .msrGetSecuredTags, .nfcGetAuthorizationSecuredTags, .nfcGetAuthorizationPlainTags:
                message = "Processing..., please wait"
            case .smcFinalizeTransaction, .completeNFCTransaction, .nfcGetFinalizationPlainTags, .nfcGetFinalizationSecuredTags:
                message = "Finalization..., please wait"
            case .smcRemoveCard:
                message = "Please remove card"
            case .msrOnlinePIN:
                message = "Pin online..."
            case .authorization:
                message = "Authorization processing"
            case .exitSecureSession:
                message = "Transaction complete"
            case .displayResult:
                message = "Displaying result on device"
            case .getL1Log, .getL2Log:
                message = "Getting transaction logs..."
            default:
                break
            }
            self.presentAlert(title: nil, message: message)
        }
            , didFinish: { (success: Bool, context: PaymentContext) in
                self.dismissAlert()
                LogManager.debug(message: "Payment did finish with status: \(context.paymentStatus?.name ?? "unknown")")
                self.paymentResultLabel.text = (context.paymentStatus?.name ?? "unknown")
                self.paymentResultLabel.isHidden = false
            if let uCubeFirmware = context.uCubeInfo?.parseTLV()[RPC.Tag.firmwareVersion] {
                LogManager.debug(message: "uCube firmware version: \(uCubeFirmware.parseVersion())")
            }
            if let activatedReader = context.activatedReader {
                LogManager.debug(message: "Used interface: \(CardReaderType.getLabel(code: activatedReader) ?? "unknown")")
            }
            LogManager.debug(message: "amount: \(context.getAmount())")
            LogManager.debug(message: "currency: \(context.currency?.label ?? "unknown")")
            LogManager.debug(message: "tx date: \(context.transactionDate?.description ?? "unknown")")
            LogManager.debug(message: "tx type: \(context.transactionType?.label ?? "unknown")")
            if let selectedApplication = context.selectedApplication {
                LogManager.debug(message: "app ID: \(selectedApplication.getLabel() ?? "unknown")")
                LogManager.debug(message: "app version: \(context.applicationVersion?.description ?? "unknown")")
            }
            LogManager.debug(message: "system failure log1: \(context.systemFailureInfo?.hexString ?? "unknown")")
            LogManager.debug(message: "system failure log2: \(context.systemFailureInfo2?.hexString ?? "unknown")")
            if let plainTagTLV = context.finalizationPlainTagsValues {
                for (tag, value) in plainTagTLV {
                    LogManager.debug(message: "Plain tag: 0x\(tag.hexString), \(tag) = 0x\(value.hexString)")
                }
            }
            if let securedTagBlock = context.finalizationSecuredTagsValues {
                LogManager.debug(message: "secured tag block: \(securedTagBlock.hexString)")
            }
        })
    }
    
    @IBAction func changeTransactionType(_ sender: Any) {
        let completion = { (type: TransactionType) in
            self.transactionType = type
            self.transactionTypeLabel.text = type.label
        }
        let alert = UIAlertController(title: "Choose a transaction type", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: TransactionType.purchase.label, style: .default) { _ in
            completion(.purchase)
        })
        alert.addAction(UIAlertAction(title: TransactionType.withdrawal.label, style: .default) { _ in
            completion(.withdrawal)
        })
        alert.addAction(UIAlertAction(title: TransactionType.refund.label, style: .default) { _ in
            completion(.refund)
        })
        alert.addAction(UIAlertAction(title: TransactionType.purchaseCashback.label, style: .default) { _ in
            completion(.purchaseCashback)
        })
        alert.addAction(UIAlertAction(title: TransactionType.manualCash.label, style: .default) { _ in
            completion(.manualCash)
        })
        alert.addAction(UIAlertAction(title: TransactionType.inquiry.label, style: .default) { _ in
            completion(.inquiry)
        })
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func changeCurrency(_ sender: Any) {
        let completion = { (currency: Currency) in
            self.currency = currency
            self.currencyLabel.text = currency.label
        }
        let alert = UIAlertController(title: "Choose a currency", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: UCubePaymentRequest.currencyEUR.label, style: .default) { _ in
            completion(UCubePaymentRequest.currencyEUR)
        })
        alert.addAction(UIAlertAction(title: UCubePaymentRequest.currencyUSD.label, style: .default) { _ in
            completion(UCubePaymentRequest.currencyUSD)
        })
        present(alert, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
