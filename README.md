# YouTransactor mPOS SDK - IOS

###### Release 0.5.23

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


#### Transaction types
```swift
purchase
withdrawal
refund
purchaseCashback
manualCash
inquiry
```

#### Pay API
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
#### UCubePaymentRequest
```swift
// non optional variables
var paymentRequest = UCubePaymentRequest(amount: amountValue, currency: currency, transactionType: transactionType, readers: readers, authorizationTask: AuthorizationTask(presenter: self), preferredLanguages: ["en"] )
        
// optional variables
paymentRequest.cardWaitTimeout = cardWaitTimeout
paymentRequest.systemFailureInfo2 = false
paymentRequest.forceDebug = false
paymentRequest.transactionDate = Date()
paymentRequest.forceAuthorization = forceAuthorizationSwitch.isOn
paymentRequest.forceOnlinePIN = forceOnlinePinSwitch.isOn
paymentRequest.authorizationPlainTags = [
            RPC.EMVTag.TAG_4F_APPLICATION_IDENTIFIER,
            RPC.EMVTag.TAG_50_APPLICATION_LABEL,
            RPC.EMVTag.TAG_5F2A_TRANSACTION_CURRENCY_CODE,
            RPC.EMVTag.TAG_5F34_APPLICATION_PRIMARY_ACCOUNT_NUMBER_SEQUENCE_NUMBE
	    ]
paymentRequest.authorizationSecuredTags = [
            RPC.EMVTag.TAG_SECURE_5A_APPLICATION_PRIMARY_ACCOUNT_NUMBER,
            RPC.EMVTag.TAG_SECURE_57_TRACK_2_EQUIVALENT_DATA,
            RPC.EMVTag.TAG_SECURE_56_TRACK_1_DATA,
            RPC.EMVTag.TAG_SECURE_5F20_CARDHOLDER_NAME
	    ]
paymentRequest.finalizationPlainTags = [
            RPC.EMVTag.TAG_8E_CARDHOLDER_VERIFICATION_METHOD_LIST,
            RPC.EMVTag.TAG_95_TERMINAL_VERIFICATION_RESULTS,
            RPC.EMVTag.TAG_9B_TRANSACTION_STATUS_INFORMATION,
            RPC.EMVTag.TAG_99_TRANSACTION_PERSONAL_IDENTIFICATION_NUMBER_DATA
	    ]	    
paymentRequest.finalizationSecuredTags = [
	   RPC.EMVTag.TAG_SECURE_5F24_APPLICATION_EXPIRATION_DATE,
           RPC.EMVTag.TAG_SECURE_5F30_SERVICE_CODE
	   ]
paymentRequest.riskManagementTask = RiskManagementTask(presenter: self)
	    

```
#### PaymentContext
```swift
    /* input common */
    public var cardWaitTimeout : TimeInterval = 30
    public var amount: UInt64 = 0
    public var currency: Currency = Currency(label: "EUR", code: 978, exponent: 2)
    public var transactionType: TransactionType?
    public var transactionDate: Date?
    public var applicationVersion: Int?
    public var preferredLanguages: [String]?
    public var forceOnlinePIN: Bool = false
    private var forceAuthorization: Bool = false
    public var onlinePinBlockFormat: UInt8 = RPC.PIN.blockISO9564Format0
    public var readers: [CardEntryMode] = [.ICC, .NFC]
    public var getSystemFailureInfoL2: Bool = false // user choose to get logs at the end of transaction
    public var forceDebug: Bool = false // sdk can force getting logs at the end of transaction if status != approved
    
    /* input NFC & ICC */
    public var authorizationPlainTags: Set<Int>?
    public var authorizationSecuredTags: Set<Int>?
    public var finalizationPlainTags: Set<Int>?
    public var finalizationSecuredTags: Set<Int>?
    
    /* output common */
    public var paymentStatus: PaymentStatus? // END status*/
    public var uCubeInfo: Data?
    public var sredKsn: Data?
    public var pinKsn: Data?
    public var cardEntryMode: CardEntryMode?
    public var onlinePinBlock: Data?
    public var finalizationPlainTagsValues: [Int: Data]?
    public var authorizationPlainTagsValues: [Int: Data]?
    public var finalizationSecuredTagsValues: Data?
    public var authorizationSecuredTagsValues: Data?
    public var authorizationResponse: Data? //0x8A
     
     /* output nfc */
    public var nfcOutcome: Data?
    public var signatureRequired: Bool = false

    /* output icc */
    public var selectedApplication: EMVApplicationDescriptor?
    private var tvr: Data = Data(repeating: 0, count: 5)
    public var transactionFinalisationData: Data?
    public var transactionInitData: Data?
    public var transactionProcessData: Data?
    
    /* output for debug */
    public var tagCC: Data? // svpp logs level 2 tag CC
    public var tagF4: Data? // svpp logs level 2 tag F4
    public var tagF5: Data? // svpp logs level 2 tag F5
```

#### PaymentState 
```swift
// Common states
    startCancelAll
    startExitSecureSession
    getInfo
    enterSecureSession
    ksnAvailable
    startTransaction
    cardReadEnd
        
    // Authorization
    authorization
        
    // End
    getFinalizationSecuredTags
    getFinalizationPlainTags
    getCCL2Log
    getF4L2Log
    getF5L2Log
    endExitSecureSession
    
    // SMC states
    smcBuildCandidateList
    smcSelectApplication
    smcUserSelectApplication
    smcInitTransaction
    smcRiskManagement
    smcProcessTransaction
    smcGetAuthorizationSecuredTags
    smcGetAuthorizationPlainTags
    smcFinalizeTransaction
    smcRemoveCard

    // NFC states
    nfcGetAuthorizationSecuredTags
    nfcGetAuthorizationPlainTags
    nfcSimplifiedOnlinePin
    nfcCompleteTransaction
    
```

#### EMV Payment state machine

![Document sans titre](https://user-images.githubusercontent.com/59020462/110345361-c5c7f900-802e-11eb-9748-94ddd0645aab.png)

The EMV payment state machine is sequence of executing commands and tasks. Bellow you will see the different tasks used at transaction

#### Tasks
Durring the payment process the payment state machine will be interrupted to execute some tasks that you implement.

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

  @Override
  public func cancel(completion: (Bool) -> Void) {
      monitor?.eventHandler(.cancelled, [])
      completion(true)
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

  @Override
  public func cancel(completion: (Bool) -> Void) {
      monitor?.eventHandler(.cancelled, [])
      completion(true)
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

  @Override
  public func cancel(completion: (Bool) -> Void) {
      monitor?.eventHandler(.cancelled, [])
      completion(true)
  }
}
```
##### PaymentStatus
```swift
    approved, // Transaction has been approved by terminal
    declined, // Transaction has been declined by terminal
    /* Cancelled Status cases:
        1/ GPO not read yet and application calls payment.cancel()
        2/ one of commands returns -32 or -28 status
        3/ NFC_Outcome[1] = 0x3A Transaction_cancelled
    */
    cancelled,

    cardWaitFailed,//Transaction has been failed because customer does not present a card and startNFCTransaction fail
    unsupportedCard, ///Transaction has been failed: Error returned by terminal, at contact transaction, when no application match between card and terminal's configuration

    nfcOutcomeTryOtherInterface, // Transaction has been failed: Error returned by terminal, at contactless transaction
    nfcOutcomeEndApplication,// Transaction has been failed: Error returned by terminal, at contactless transaction
    nfcOutcomeFailed,// Transaction has been failed: Error returned by terminal, at contactless transaction

    error, // Transaction has been failed : when one of the tasks or commands has been fail
    errorDisconnect,//Transaction has been failed : when there is a disconnect during the transaction
    errorShuttingDown,//Transaction has been failed : when command fails with SHUTTING_DOWN error during the transaction
    errorWrongActivatedReader, // Transaction has been failed : when terminal return wrong value in the tag DF70 at startNFCTransaction
    errorMissingRequiredCryptogram,// Transaction has been failed :when the value of the tag 9f27 is wrong
    errorWrongCryptogramValue, // Transaction has been failed : when in the response of the transaction process command the tag 9F27 is missing
    errorWrongNfcOutcome, // Transaction has been failed : when terminal returns wrong values in the nfc outcome byte array
}
```

#### Cancel Payment 
During the transaction, Customer may need to cancel payment. This is only possible before terminal reads card with success, in other words the GPO of card was successfully read. The cancel method returns a callback with status of cancellation. Here is a figure that resume the two kind of states, blue ones the cancellation is possoble the red ones the cancellation not possible. Note that at the end of startTransaction state, if the reader interface was NFC, so the card  was successfully read. The startTransaction step do the wait card and the read card for contactless and only the wait card for contact.  

![payment states](https://user-images.githubusercontent.com/59020462/110348022-7e8f3780-8031-11eb-96a3-35c67997a7e2.png)

```java
            emvPaystateMachine = UCubeAPI.pay(...);
	    
	   ....
	    emvPaystateMachine.cancel{ (status) in
            //TODO : do stuff here
        }
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
