# YouTransactor mPOS SDK - IOS

###### Release 0.2.0

<p>
  <img src="https://user-images.githubusercontent.com/59020462/86530425-e563bc00-beb8-11ea-821d-23996a2187da.png">
</p>

This repository provides step by step documentation for the integration of YouTransactor's native iOS SDK to drive our proprietary uCube terminal to accept credit and debit card payments (incl. VISA, MasterCard, American Express and more).

For the Android version of the SDK, please refer to the [Android documentation](https://github.com/YouTransactor/mPOS-SDK-Android/blob/master/README.md)

## Summary

The interactions between the mobile device and the card terminal is a Master-Slave relation in which the mobile device drives the card terminal by calling the various terminal commands. The SDK provides payment, update, and log APIs. The main purpose of the SDK is to send RPC commands to the card terminal to sequence operations.

The SDK includes the following modules: Connexion, RPC, MDM, Payment, Log.

- The connexion module provides an 'IconnexionManager' interface, so you can use your implementation, and provides a Bluetooth Low Energy (BLE) implementaion.
- The RPC module uses the IconnexionManager implementation to send RPC commands and receive responses from the card terminal. It provides an implementation of all the device RPCs.
- The MDM module is an implementation of all YouTransactor's TMS services. The TMS server is mainly used to manage the firmware updates and ICC / NFC parameter configurations of the terminal. The SDK allows transparent update of the card terminal when using our TMS. This module is not required if you choose to use your own TMS.
- The payment module implements the transaction processing for contact and contactless payments. For each transaction, a UCubePaymentRequest instance must be provided as input to configure the current operation. A callback is called at every progress step of the transaction, and a PaymentContext instance is returned when the transaction is complete and contains all the necessary data to record the transaction.
- The SDK provide an ILogger interface and a default implementation to manage logs. Your application can choose between using the default implementation, which print the logs in a file that can be sent to our TMS server, or use your own implementation of ILogger.

All SDK features are gathered in a single Class: UCubeAPI. This class provides public static methods that your application can use to setup ConnexionManager, setup Logger, perform a payment, perform an update using our TMS...

The SDK does not save any connection or transaction or update data.

For more information about YouTransactor developer products, please refer to our [www.youtransactor.com](https://www.youtransactor.com).

## I. General overview

### 1. Introduction

The YouTransactor mPOS card terminal supported by this SDK is the uCube Touch. This documentation describes the YouTransactor iOS SDK implementation that complements the uCube Touch.

The iOS SDK manages the Payment Transaction (EMV Contact, EMV CLess) by driving the uCube Touch. It provides all required transaction data to allow the payment application to connect to the payment processor for authorization and transaction completion. It also connects to the YouTransactor TMS (Terminal Management System) used to update the uCube Touch firmware and the EMV parameters.

This document presents the iOS SDK architecture, describes the transaction flow, details how the SDK can be integrated to an iOS payment application, and provides sample codes.

### 2. uCube Touch

The uCube Touch is a lightweight and compact payment dongle. It can turn a tablet or a mobile device, Android or iOS, into a point of sale via a BLE connection to enable acceptance of contact and contactless payment cards.

<p align="center">
  <img width="250" height="250" src="https://user-images.githubusercontent.com/59020462/77367842-437df080-6d5b-11ea-8e3a-423c3bc6b96b.png">
</p>

### 3. Mobile Device

The mobile device can be either Android or iOS and typically hosts applications related to payment. It links the card terminal to the rest of the system.

The mobile device application consists of 2 modules:

- Business module
  - Application that meets the business needs of the end customer. This is for example a cashier application in the case of a restaurant, or a control application in the case of transports.
- Payment Module
  - Drives the transaction
  - Responsible for device software/configurations updates

The business module on the mobile device is developed by you. It uses the mobile device's user interface to fulfill the business needs of the customer.

The Payment module integrates our SDK, delivered as a library, to create the payment application.

### 5. The Management System

The management system can be administered by YouTransactor and offers the following services:

- Management of the uCube fleet
- Deployment of software updates
- Deployment of payment parameters
- Other services

The MDM module of SDK implements all our management system services and the UCubeAPI provides methods to call these features.

### 6. Terminal management

#### 6.1 Initial configuration

To be functional, in the scope of PCI PTS requirements, an SRED key shall be loaded securely in the device. This key is loaded locally by YouTransactor tools. The initial SALT is injected in the same way.

#### 6.2 Switching On/Off

The uCube lights up by pressing the "ON / OFF" button or when a BLE connection is established. Once the device is on, the payment process can be initiated. The uCube switches off either by pressing the "ON / OFF" button or after **X** minutes of inactivity (**X** = OFF timeout).

#### 6.3 Update

The terminal firmware can be updated remotely to add bug fixes, evolutions... Contact and contactless configuration can also be updated remotely.

The Terminal's documentation describe how these updates can be performed and what RPC commands to use.

If you choose to use our TMS, this can be done transparently by first calling the `mdmCheckUpdate` method to get the TMS configuration, compare it with current device versions, and then use the `mdmUpdate` to download & intall the binary update.

#### 6.4 System logs

The SDK prints logs in logcat at runtime. The log module uses a default ILogger implementation that prints these logs in a file which can then be uploaded to a remote server.

Our TMS provides a Web Service that accepts a zip of log files. You can choose to setup the log module to use our default implementation or implement your own.

## II. Technical Overview

### 1. General Architecture

This diagrams describes the general YouTransactor MPOS iOS SDK architecture.

Only the uCubeAPI methods and the RPC commands are public and can be called by the payment application.

![archi_sdk_mpos_ios](https://user-images.githubusercontent.com/59020462/86530543-d16c8a00-beb9-11ea-80b0-1dd8e927437e.png)

### 2. Transaction Flow : Contact

![Cptr_Transaction](https://user-images.githubusercontent.com/59020462/71239375-b44de080-2306-11ea-9c32-f275a5407801.jpeg)

### 3. Transaction Flow : Contactless

![Cptr_TransactionNFC](https://user-images.githubusercontent.com/59020462/71239723-8ddc7500-2307-11ea-9f07-2f4b11b42620.jpeg)

### 4. Prerequisites

The `Deployment Target` of the SDK is `iOS 10.0`.
Your Xcode project deployment target must be iOS 10.0 of later.

### 5. Installation

UCube is available through CocoaPods. To install it, simply add the following line to your Podfile:

```
pod 'UCube', :git => 'https://github.com/YouTransactor/mPOS-SDK-IOS-Framework'
```

You can import it like this:

```swift
import UCube
```

### 6. UCubeAPI

The APIs provided by UCubeAPI are:

```swift
setConnexionManager(_ connexionManager: ConnexionManager)  

setupLogger(_ logger: Loggable)  

pay(paymentRequest: UCubePaymentRequest,  
    didProgress: PaymentProgressClosure? = nil,  
    didFinish: PaymentFinishClosure)  

close()
    
/* YouTransactor TMS APIs */  

mdmSetup()  

mdmRegister(didProgress: ProgressClosure? = nil, didFinish: FinishClosure? = nil)  

mdmRegister(didProgress: ProgressClosure? = nil, didFinish: FinishClosure? = nil)  

mdmUnregister()  

isMdmManagerReady() -> Bool  

mdmCheckUpdate(forceUpdate: Bool,  
               checkOnlyFirmwareVersion: Bool,  
               didProgress: ProgressClosure? = nil,  
               didFinish: FinishClosure? = nil)  

mdmUpdate(updates: [BinaryUpdate],  
          didProgress: ProgressClosure? = nil,  
          didFinish: FinishClosure? = nil)  

mdmSendLogs(didProgress: ProgressClosure? = nil, didFinish: FinishClosure? = nil)
```

* You can use the sample app provided in this repository as a reference

#### 6.1 Connect Terminal

The ConnectionManager protocol : 

```swift
public protocol ConnectionManager {
    
    var isConnected: Bool { get }
    
    func setDevice(_ device: UCubeDevice)
    func setDevice(identifier: String, completion: ((_ device: UCubeDevice?) -> Void)? = nil)
    func getDevice() -> UCubeDevice?
    func connect(completion: @escaping ConnectionCompletion)
    func disconnect(completion: @escaping DisconnectionCompletion)
    func send(_ data: Data, completion: @escaping SendCommandCompletion)
}
```

* First you should set `Privacy - Bluetooth Always Usage Description` in Info.plist. This is required on iOS 13 or later in order to ask user permission for Bluetooth usage.

* Second you should select the device that you want to communicate with.
  * You can use the default connection manager `BLEConnectionManager.shared`

  * `BLEConnectionManager` provides a `startScan()` & `stopScan()` methods which allow you to start and stop BLE scan.  
  In the SampleApp an example of device selection using these methods is provided.

  * `BLEConnectionManager` also provides a `scanDelegate` property in order to send scan events. You need to conform to `ScanDelegate` protocol.

  ```swift  
  BLEConnectionManager.shared.scanDelegate = self
  BLEConnectionManager.shared.startScan()
  
  [...]

  func scanDidDiscoverDevice(_ device: UCubeDevice) {
    LogManager.debug(message: "Discovered device \(device.name)")
    BLEConnectionManager.shared.setDevice(device)
  }
  ```

* You can set your own instance of `BLEConnectionManager` or a different connection manager using `UCubeAPI.setConnectionManager`. 

```swift
let bleConnectionManager = BLEConnectionManager()
UCubeAPI.setConnectionManager(bleConnectionManager)
```

```swift
let customConnectionManager = CustomConnectionManager()
UCubeAPI.setConnectionManager(customConnectionManager)
```

`CustomConnectionManager` needs to conform to `ConnectionManager` protocol.

You can retrieve a previously scanned device without performing a BLE scan.  

You have to save the identifier of the device `UCubeDevice.identifier`.

```
BLEConnectionManager.shared.setDevice(identifier: identifier) { device in
    if device == nil {
        LogManager.debug(message: "No device found with identifier: \(identifier)")
    }
}
```

#### 6.2 Setup Logger

The Loggable protocol : 

```swift
public protocol Loggable {
    
  func debug(message: String, filePath: String, functionName: String)
  func error(message: String, error: Error?, filePath: String, functionName: String)
}
```
To setup the log module you should put this instructions below in your AppDelegate or main ViewController.

```swift
// If you want to use your Loggable implementation
UCubeAPI.setupLogger(MyLogger())
```

The default `Logger` is set by default.

#### 6.3 Payment

Once device is selected you can start using the YouTransactor SDK to accept card payments.
As decribed in the transaction Flow contact and contactless before, durring the payment process the payment state machine will be interrupted to execute some tasks that you implement.

#### ApplicationSelectionTasking
```swift
public class EMVApplicationSelectionTask: ApplicationSelectionTasking {

    private var applications: [EMVApplicationDescriptor]?
    private var candidates: [EMVApplicationDescriptor]?
    private var paymentContext: PaymentContext?

    public func setAvailableApplications(_ applications: [EMVApplicationDescriptor]) {
        self.applications = applications;
    }

    public func setPaymentContext(_ paymentContext: PaymentContext) {
        self.paymentContect = paymentContext;
    }

  public func getSelection() -> [EMVApplicationDescriptor] {
    return candidates
  }
  
  public func getContext() -> PaymentContext? {
    return context
  }
  
  public func setContext(_ context: PaymentContext) {
    self.context = context
  }

    @Override
    public func execute(monitor: TaskMonitoring) {
        var candidates: [EMVApplicationDescriptor] = []

        // Todo do AID selection

        monitor.eventHandler(.success, []) // should call this to return to the payment state machine
    }

}
```

#### RiskManagementTasking
 ```swift
class RiskManagementTask: RiskManagementTasking {
  private var tvr: Data = Data([0, 0, 0, 0, 0])
    private var paymentContext: PaymentContext?

  func getTVR() -> Data {
    return tvr
  }
  
  func getContext() -> PaymentContext? {
    return paymentContext
  }
  
  func setContext(_ context: PaymentContext) {
    self.paymentContext = context
  }

    public func setPaymentContext(_ paymentContext: PaymentContext) {
        self.paymentContext = paymentContext;
    }

    public func execute(monitor: TaskMonitoring) {
        // TODO: perform risk management 
        
        monitor.eventHandler(.success); // should call this to return to the payment state machine
    }
}
```
#### AuthorizationTasking
```swift
class AuthorizationTask: AuthorizationTasking {

  private var authorizationResponse: Data = Data([0x8A, 0x02, 0x30, 0x30]) // Approved
  private var paymentContext: PaymentContext?

    func getAuthorizationResponse() -> Data {
    return authorizationResponse
  }
  
  func getContext() -> PaymentContext? {
    return paymentContext
  }
  
  func setContext(_ context: PaymentContext) {
    self.paymentContext = context
  }

    public func execute(monitor: TaskMonitoring) {
        // TODO: perform authorization
        
        monitor.eventHandler(.success); // should call this to return to the payment state machine
    }
}
```

#### Transaction types
```swift
purchase
withdrawal
refund
purchaseCashback
manualCash
inquiry
```
#### UCubePaymentRequest
```swift
  var paymentRequest = UCubePaymentRequest()
    paymentRequest.amount = 15.0
    paymentRequest.currency = UCubePaymentRequest.currencyEUR // Indicates the currency code of the transaction according to ISO 4217
    paymentRequest.transactionType = .purchase
    paymentRequest.transactionDate = Date()
  paymentRequest.cardWaitTimeout = 30
  paymentRequest.displayResult = true // at the end of transaction is the SDK display the payment result on uCube or just return the result
  paymentRequest.readers = [
    RPC.Reader.icc,
    RPC.Reader.nfc
  ]
  paymentRequest.forceOnlinePIN = true // Applicable for NFC and MSR
  paymentRequest.forceAuthorization = true
  paymentRequest.requestedAuthorizationTags = [
    RPC.Tag.tvr,
    RPC.Tag.tsi
  ]
  paymentRequest.requestedSecuredTags = [
    RPC.Tag.track2EquData
  ]
  paymentRequest.requestedPlainTags = [
    RPC.Tag.msrBin
  ]
  paymentRequest.applicationSelectionTask = ApplicationSelectionTask() // if not set the SDK use the EMV default selection
  paymentRequest.authorizationTask = AuthorizationTask() // Mandatory
  paymentRequest.riskManagementTask = RiskManagementTask() // Mandatory
  paymentRequest.systemFailureInfo = true // get the transaction level 1 Logs
  paymentRequest.systemFailureInfo2 = true // get the transaction level 2 Logs\
  paymentRequest.preferredLanguages = ["en"] // each language represented by 2 alphabetical characters according to ISO 639
```

#### Pay
```swift
UCubeAPI.pay(
  paymentRequest: paymentRequest,
  didProgress: { state: ServiceState in
    // your code here
  },
  didFinish: { (success: Bool, paymentContext: PaymentContext) in
    // your code here
  }
)
```

#### PaymentState 
```swift
// COMMON STATES
cancelAll
getInfo
waitCard // Contact only state
enterSecureSession
ksnAvailable
// SMC STATES
smcBuildCandidateList
smcSelectApplication
smcUserSelectApplication
smcInitTransaction
smcRiskManagement
smcProcessTransaction
smcFinalizeTransaction
smcRemoveCard
// MSR STATES
msrGetSecuredTags
msrGetPlainTags
msrOnlinePIN
// SingleEntryPoint / NFC STATES
startNFCTransaction
nfcGetSecuredTags
nfcGetPlainTags
completeNFCTransaction
// COMMON STATES
authorization
exitSecureSession
displayResult
getL1Log
getL2Log
```
#### PaymentContext
```swift
paymentStatus: PaymentStatus? // END status

selectedApplication: EMVApplicationDescriptor?
amount: Double = -1
currency: Currency?
transactionType: TransactionType?
applicationVersion: Int?
preferredLanguages: [String]?
uCubeInfos: Data?
sredKsn: Data?
pinKsn: Data?
activatedReader: UInt8?
forceOnlinePIN: Bool = false
forceAuthorization: Bool = false
onlinePinBlockFormat: UInt8 = RPC.PIN.blockISO9564Format0
requestedPlainTags: [Int]?
requestedSecuredTags: [Int]?
requestedAuthorizationTags: [Int]?
securedTagBlock: Data?
onlinePinBlock: Data?
plainTagTLV: [Int: Data]?
authorizationResponse: Data
tvr: Data = Data(repeating: 0, count: 5)
transactionDate: Date?
nfcOutcome: Data?
transactionFinalisationData: Data?
transactionInitData: Data?
transactionProcessData: Data?
messages: [String: String]?
alternativeMessages: [String: String]?
displayResult: Bool = false
getSystemFailureInfoL1: Bool = false
getSystemFailureInfoL2: Bool = false
systemFailureInfo: Data? //svpp logs level 1
systemFailureInfo2: Data? // svpp logs level 2
```

##### PaymentStatus
```swift
nfcMPOSError
cardWaitFailed
cancelled
unsupportedCard
tryOtherInterface
refusedCard
error
approved
declined
```

#### 6.4 MDM 

#### Setup 

The main function of MDM module is the update of firmware and configurations of the terminal.

The terminal have to be registred on the TMS server using this code below: 

```swift
UCubeAPI.mdmRegister(
  didProgress: { state: ServiceState in
    //  your code here          
  },
  didFinish: { (success: Bool, parameters: [Any]?) in
    // your code here
  }
)
```
At the register process the SDK send the public certificate of terminal to the TMS, so the server can verifie the YouTransactor signature and then generate and return an SSL certificate unique by terminal. This SSL certificate is used to call the rest of web services.
Note that the register should be done only once, at the selection of terminal. the SDK save the SSL certificate and to be removed you have to call this method below.

```swift
let success: Bool = UCubeAPI.mdmUnregister()
if(!success) {
  LogManager.error(message: "FATAL Error! error to unregister current device")
}
```
To check if the SSL certificate exit, use this method : 
```swift
UCubeAPI.isMDMManagerReady()
```
#### Update

The update can be done in two steps, check the TMS configuration and compare it with current versions this is performed by the `mdmCheckUpdate` method and then download the binary(ies) from TMS server and install them and this can be done by the `mdmUpdate` method.

```swift
UCubeAPI.mdmCheckUpdate(
  forceUpdate: false,  
  checkOnlyFirmwareVersion: false, 
  didProgress: { state: ServiceState in
    // your code here
  },
  didFinish: { (success: Bool, parameters: [Any]?) in
    if success {
      let updates = parameters[0] as! [BinaryUpdate]
      let configs = parameters[1] as! [Config]

      if updates.count == 0 {
        print("Terminal up to date")
      } else {
        // TODO: call mdmUpdate with in input a [BinaryUpdate]
      }
    }
  }
)
```

```swift 
UCubeAPI.mdmUpdate(
  updates: selectedUpdateList,, 
  didProgress: { state: ServiceState in
    // your code here
  },
  didFinish: { (success: Bool, parameters: [Any]?) in
    // your code here
  }
)
```

#### Send Logs

Sending Logs to the server is useful in case of debug. The TMS server provides a web service to receive these log files and the SDK implement the call of this ws. 

```swift 
UCubeAPI.mdmSendLogs(
  didProgress: { state: ServiceState in
    // your code here
  },
  didFinish: { (success: Bool, parameters: [Any]?) in
    // your code here
  }
)
```

### 7. RPC Commands

Once the connectionManager set and the device selected. You can call any RPC commands implemented in the SDK. This is the list of RPC Commands class: 

```swift
/* System & Drivers */
GetInfoCommand.swift
SetInfoFieldCommand.swift
WaitCardCommand.swift
WaitCardRemovalCommand.swift
DisplayChoiceCommand.swift
DisplayMessageCommand.swift
PowerOffCommand.swift
CancelCommand.swift

/* System kernel */
EnterSecureSessionCommand.swift
ExitSecureSessionCommand.swift
InstallForLoadCommand.swift
InstallForLoadKeyCommand.swift
LoadCommand.swift
SimplifiedOnlinePINCommand.swift

/* Payment kernel */
BankParametersDownloads.swift
GetEMVParametersCommand.swift
BuildCandidateListCommand.swift
StartNFCTransactionCommand.swift
CompleteNFCTransactionCommand.swift
GetPlainTagCommand.swift
GetSecuredTagCommand.swift
InitTransactionCommand.swift
TransactionFinalizationCommand.swift
TransactionProcessCommand.swift
```

All this commands are described in the terminal documentation.

* This is an example of command call: 

```swift
let displayMessageCommand = DisplayMessageCommand(message: message)

displayMessageCommand.setCentered(centered)
displayMessageCommand.setYPosition(yPosition)
displayMessageCommand.setFont(font)

displayMessageCommand.execute(
  monitor: TaskMonitor { (event: TaskEvent, parameters: [Any]) in
    switch event {
    case .failed:
        // your code here
    case .success:
        // your code here
    default:
        break
    }
  }
)
```

![Cptr_logoYT](https://user-images.githubusercontent.com/59020462/71242500-663cdb00-230e-11ea-9a07-3ee5240c6a68.jpeg)