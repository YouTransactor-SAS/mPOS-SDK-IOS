//
//  Constants.swift
//  uCube
//
//  Created by Rémi Hillairet on 5/27/20.
//  Copyright © 2020 YouTransactor. All rights reserved.
//

import CoreBluetooth

typealias BLEConnection = Constants.BLEConnection
typealias MDM = Constants.MDM
public typealias RPC = Constants.RPC

public struct Constants {
    
    static var isDebug: Bool {
        
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    struct BLEConnection {
        
        static let scanDurationInSeconds: Double = 10
        static let connectionTimeOutInSeconds: Double = 15
        
        static let hStateUndetermined: UInt8 = 0xFF
        static let hStatePoweredOff: UInt8 = 0x30
        static let hStatePoweredOn: UInt8 = 0x31
        
        static let uCubeServiceUUID = CBUUID(string: "11A7A236-D841-42D1-A99C-061C6E909BF9")
        static let uCubeTxRxUUID = CBUUID(string: "D1F4C2D0-F8C2-4565-9349-E0312EFFD1EE")
        static let uCubeConnectedPasswordUUID = CBUUID(string: "4E6EFAB4-7028-49D4-8458-95E69A93607D")
        static let uCubeHStateUUID = CBUUID(string: "D329A8CB-B872-4C13-971B-72BCA85EF0CD")
        
        static let uCubeTxDataMaxSize = 20
    }
 
    struct MDM {
        
        static let urlProtocol: String = "https://"
        static let urlPrefix: String = "/MDM/jaxrs"
        static var publicHostname: String {
            if isDebug {
                return "public-api.mdm-dev.youtransactor.com"
            } else {
                return "public-api.mdm.youtransactor.com"
            }
        }
        static var privateHostname: String {
            if isDebug {
                return "private-api.mdm-dev.youtransactor.com"
            } else {
                return "private-api.mdm.youtransactor.com"
            }
        }
        static let publicBaseURL = "\(urlProtocol)\(publicHostname)\(urlPrefix)"
        static let privateBaseURL = "\(urlProtocol)\(privateHostname)\(urlPrefix)"
        
        struct Endpoint {
            
            static let register: String = "\(publicBaseURL)/public/v1/dongle/register/"
            static let logs: String = "\(publicBaseURL)/public/v3/dongle/logs/"
            static let binary: String = "\(privateBaseURL)/v3/dongle/binary/"
            static let checkState: String = "\(privateBaseURL)/v3/dongle/checkState/"
            static let config: String = "\(privateBaseURL)/v3/dongle/config/"
        }
        
        struct Types {
            
            public static let svppFirmware = 0
            public static let stFirmware = 3
            public static let iccConfig = 4
            public static let nfcConfig = 5
            public static let additionalFiles = 8
        }
    }
    
    public struct RPC {
        
        // Secure session management constants
        static let headerLen: UInt8 = 0x05
        static let securedHeaderCryptoRNDLen: UInt8 = 0x01
        static let securedHeaderLen: UInt8 = headerLen + securedHeaderCryptoRNDLen
        static let sredMacSize: UInt8 = 0x04
        
        // Return code
        static let successStatus = 0
        static let timeoutStatus = -2
        static let cancelledStatus = -32
        static let emvNotSupport = -300
        static let emvNotAccept = -301
        static let ecmdAborted = -114
        static let actionCancelled = -28
        static let noCard = -35
        static let badTerminalState = -287
        
        static let mPOSErrorStart = -0x1020
        static let mPOSErrorEnd = -0x1030
        static let mPOSNotReady = -0x102A
        
        static let emvApplicationCandidateBlockSize = 64
        
        struct MSRAction {
            static let none: UInt8 = 0x00
            static let onlinePINRequired: UInt8 = 0x01
            static let chipRequired: UInt8 = 0x02
            static let decline: UInt8 = 0x04
        }
        
        struct Command {
            
            static let cancel: UInt16 = 0x0202
            static let getInfo: UInt16 = 0x5001
            static let setInfoField: UInt16 = 0x5003
            static let cardWaitInsertion: UInt16 = 0x5020
            static let cardWaitRemoval: UInt16 = 0x5021
            static let getSecuredTagValue: UInt16 = 0x5025
            static let getPlainTagValue: UInt16 = 0x5026
            static let displayWithoutKI: UInt16 = 0x5040
            static let displayListboxWithoutKI: UInt16 = 0x5042
            static let enterSecuredSession: UInt16 = 0x5101
            static let exitSecuredSession: UInt16 = 0x5102
            static let installForLoadKey: UInt16 = 0x5130
            static let installForLoad: UInt16 = 0x5160
            static let load: UInt16 = 0x5161
            static let simplifiedOnlinePIN: UInt16 = 0x5171
            static let buildCandidateList: UInt16 = 0x5510
            static let transactionInit: UInt16 = 0x5511
            static let transactionProcess: UInt16 = 0x5512
            static let transactionFinal: UInt16 = 0x5513
            static let startNFCTransaction: UInt16 = 0x5530
            static let completeNFCTransaction: UInt16 = 0x5531
            static let powerOff: UInt16 = 0x5060
            static let bankParametersDownloads: UInt16 = 0x5501
            static let getEMVParameters: UInt16 = 0x5503
        }
        
        struct Header {
            static let stx: UInt8 = 0x02
            static let etx: UInt8 = 0x03
        }
        
        struct Mode {
            // POS entry mode
            static let msrPOSEntry: UInt8 = 0x02
            static let iccPOSEntry: UInt8 = 0x09
            
            // PIN input correction key action
            struct CorrectionKey {
                static let eraseLastDigitPINInput: UInt8 = 0x01
                static let eraseAllPINInput: UInt8 = 0x02
            }
        }
        
        struct PIN {
            // Online PIN block format
            static let blockISO9564Format0: UInt8 = 0
            static let blockISO9564Format1: UInt8 = 1
            static let blockISO9564Format3: UInt8 = 3
        }
        
        struct Reader {
            static let icc: UInt8 = 0x11
            static let nfc: UInt8 = 0x21
            static let ms: UInt8 = 0x41
        }
        
        struct Size {
            static let status: UInt8 = 0x02
            static let protocolBytes: UInt8 = 0x04
        }
        
        public struct Tag {
            // PLAIN & SECURED PROPRIETARY TAGS
            public static let msrAction = 0xDF60
            public static let msrBin = 0xDF61
            public static let cardDataBlock = 0xDF62
            public static let track2EquData = 0x57
            public static let tvr = 0x95
            public static let tsi = 0x9B
            // GET INFO TAGS
            public static let atmelSerial = 0xC1
            public static let terminalPN = 0xC2
            public static let terminalSN = 0xC3
            public static let terminalState = 0xC4
            public static let batteryState = 0xC5
            public static let powerOffTimeout = 0xC6
            public static let ksnFormats = 0xCD
            public static let firmwareVersion = 0xD1
            public static let svppChecksum = 0xD2
            public static let pciPedVersion = 0xD3
            public static let pciPedChecksum = 0xD4
            public static let emvL1Version = 0xD5
            public static let emvL1Checksum = 0xD6
            public static let emvL2Version = 0xD7
            public static let emvL2Checksum = 0xD8
            public static let bootLoaderVersion = 0xD9
            public static let bootLoaderChecksum = 0xDA
            public static let kslID = 0xDB
            public static let nfcInfo = 0xE8
            public static let emvICCConfigVersion = 0xEA
            public static let emvNFCConfigVersion = 0xEB
            public static let mPOSModuleState = 0xED
            public static let emvL1NFCVersion = 0xA0
            public static let emvL2NFCVersion = 0xA2
            public static let osVersion = 0xEC
            public static let usbCapability = 0xE9
            public static let nfcFirmwareState = 0xC4
            public static let emvL1ClessLibVersion = 0xA0
            public static let tstLoopbackVersion = 0xA1
            public static let agnosLibVersion = 0xA2
            public static let aceLayerVersion = 0xA3
            public static let gpiVersion = 0xA4
            public static let emvL3Version = 0xA5
            public static let paymentAppClessVersion = 0xA6
            public static let systemFailureLogRecord1 = 0xCB
            public static let systemFailureLogRecord2 = 0xCC
            public static let transactionConfig = 0xF0
            public static let transactionData = 0xF1
            // APP Candidate TLV Tags
            public static let appAid = 0x84
            public static let appPreferredName = 0x9F12
            public static let appLabel = 0x50
            public static let appPriorityIndex = 0x87
            public static let appIssuerCodeIndex = 0x9F11
            public static let appSelectOpt = 0xDF22
            public static let appStatus = 0xDF04
            public static let appLanguage = 0x5F2D
            public static let appSrpd = 0x9F0A
            public static let appFciIssuerDiscretionaryData = 0xBF0C
            // EMV Standardized TAGS
            public static let cryptogramInfoData = 0x9F27
            public static let emvApplicationLabel = 0x50
            public static let applicationId = 0x84
            public static let emvApplicationPreferredName = 0x9F12
            public static let emvCvmResult = 0x9F34
            public static let emvPosEntryMode = 0x9F39
            public static let emvAuthCode = 0x8A
            public static let emvIad = 0x91
            public static let emvIssuerScript1 = 0x71
            public static let emvIssuerScript2 = 0x72
            public static let nfcFormFormat = 0x9F6E
            // Build Candidate List Parameters
            public static let outputFormat = 0xC2
            public static let legacyOutput = 0x00
            public static let fullTLVOutput = 0x01
            public static let nbApp = 0xC3
            // GENERATE AC Cryptogram types
            public static let arqc = 0x80
            public static let tc = 0x40
            public static let aac = 0x00
            // SMC PAYMENT PROPRIETARY TAGS and Values
            public static let pinKsn = 0xDF3E
            public static let pinBlock = 0xDF3F
            public static let checkTransactionInitStatus = 0xDF42
            public static let ksnLength = 10
            public static let pinBlockLength = 8
        }
        
        struct TransactionType {
            static let purchase: UInt8 = 0x00
            static let cash: UInt8 = 0x01
            static let purchaseCashback: UInt8 = 0x09
            static let refund: UInt8 = 0x20
            static let manualCash: UInt8 = 0x12
            static let inquiry: UInt8 = 0x31
        }
    }
}
