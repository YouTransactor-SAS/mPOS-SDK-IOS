# YouTransactor mPOS SDK - IOS

###### Release 1.0.0.0

<p>
  <img src="https://user-images.githubusercontent.com/59020462/86530425-e563bc00-beb8-11ea-821d-23996a2187da.png">
</p>

This repository provides a step by step documentation for YouTransactor's native IOS SDK, that enables you to integrate our proprietary card terminal(s) to accept credit and debit card payments (incl. VISA, MasterCard, American Express and more). The relation between the mobile device and the card terminal is a Master-Slave relation, so the mobile device drives the card terminal by calling diffrent available commands. The main function of the SDK is to send RPC commands to the card terminal in order to drive it. The SDK provides also a payment, update and log APIs. 

The SDK contains several modules: Connexion, RPC, MDM, Payment, Log.
* The connexion module provides an interface 'IconnexionManager' so you can use your implementation and also it provides a Bluetooth Low Energy (BLE)  implementaions.
* The RPC module use the IconnexionManager implementation to send/receive, RPC command/response from card terminal. It provides an implementation of all RPC commands you will see next how to use that in your application.
* The MDM module is an implementation of all YouTransactor's TMS services. The TMS server is mainly used to manage the version of firmware and ICC / NFC configurations of card terminal. So the SDK allows you to transparently update of the card terminal using our TMS. This module is useless if you decide to use another TMS not the YouTransactor one.
* The payment module implements the transaction processing for contact and contactless. For every payment, a UCubePaymentRequest instance should be provided as input to configure the current payment and durring the transaction a callback is returned for every step. At the end of transaction a PaymentContext instance is returned which contains all necessary data to save the transaction. An example of Payment call is provided next.
* The SDK provide an ILogger interface and a default implementation to manage logs. Your application has the choice between using the default implementation which print the logs in a file that can be sent to our TMS server or you can use your own implementation of ILogger. 

All this functions are resumed in one Class which is UCubeAPI. This class provides public static methods that your application can use to setup ConnexionManager, setup Logger, do a payment, do an update using Our TMS...

The SDK do not save any connexion or transaction or update data. 

For more information about YouTransactor developer products, please refer to our [www.youtransactor.com](https://www.youtransactor.com).

## I. General overview 

### 1. Introduction

YouTransactor mPOS card terminal supported by this SDK is the uCube Touch mPOS.
         
This note describes the YouTransactor IOS SDK implementation that complements the uCube Touch. The IOS SDK handles the Payment Transaction (EMV Contact, EMV CLess) by driving the uCube Touch. It connects to the processor for authorization and transaction completion. It also connects to the YouTransactor TMS (Terminal Management System). The TMS is used to update the EMV parameters in the uCube Touch and to update the firmware of the uCube Touch. 

This document provides an architecture of the IOS SDK, describes the transaction flow, the way the SDK can be integrated to an IOS payment application and provides sample codes.

### 2. uCube Touch

The uCube Touch is a lightweight and compact payment dongle. It can turns a tablet or a mobile device, Android or iOS, into a point of sale, via a BLE connection to enable acceptance of contactless and smart payment cards.

<p align="center">
  <img width="250" height="250" src="https://user-images.githubusercontent.com/59020462/77367842-437df080-6d5b-11ea-8e3a-423c3bc6b96b.png">
</p>

### 3. Mobile Device

The mobile device can be either Android or iOS and typically hosts applications related to payment. It links the card terminal to the rest of the system.

The mobile device application consists of 2 modules:
* Business module
	* Application that meets the business needs of the end customer. This is for example a cashier    	    application in the case of a restaurant, or a control application in the case of transports.
* Payment Module
	* Drives the transaction
	* Responsible for device software/configurations updates

The business module on the mobile device is developed by you. It uses the user interfaces of the mobile device to fulfill the business needs of the customer.

The Payment module integrates our SDK, which is delivered as a library, and compiled with the payment module to generate the payment application.

### 5. The Management System

The management system can be administered by YouTransactor and offers the following services:
* Management of the uCube fleet
* Deployment of software updates
* Deployment of payment parameters
* Other services

The MDM module of SDK implements all our management system services and the UCubeAPI provides methods to call this implementation. Examples are provided next in this documentation.

### 6. Terminal management

#### 6.1 Initial configuration  

To be functional, in the scope of PCI PTS requirement, and SRED key shall be loaded securely in the device. This key is loaded locally by YouTransactor tools. The initial SALT is injected in the same way.

#### 6.2 Switching On/Off

The uCube lights up by pressing the "ON / OFF" button or by BLE connection establishment. Once the device is on, the payment process can be initiate. The uCube switches off either by pressing the "ON / OFF" button or after X* minutes of inactivity (*X = OFF timeout). 

#### 6.3 Update

During the life of the terminal, the firmware could be updated (to get bug fix, evolutions..), the contact and contactless configuration also could be updated. The Terminal's documentation describe how these updates can be done and which RPC to use to do that.

If you will use our TMS, this can be done transparentlly by calling first the ` mdmCheckUpdate`  method to get the TMS configuration and compare it with current versions, then the ` mdmUpdate`  to download & intall the binary update.

#### 6.4 System logs

The SDK prints logs in logcat at runtime. The log module use a default ILogger implementation that prints these logs in a file which can be sent afterwards to a remote server. Our TMS provides a WS to receive a zip of log files.
So you can setup the log module to use the default implementation or your own implementation. 

## II. Technical Overview

### 1. General Architecture

This diagrams describes the general YouTransactor MPOS IOS SDK architecture. Only the uCubeAPI methods and the RPC commands are public and you can call them. 


![archi_sdk_mpos_ios](https://user-images.githubusercontent.com/59020462/86530495-6a4ed580-beb9-11ea-83c7-6d0b3a1fb666.png)

### 2. Transaction Flow : Contact

![Cptr_Transaction](https://user-images.githubusercontent.com/59020462/71239375-b44de080-2306-11ea-9c32-f275a5407801.jpeg)

### 3. Transaction Flow : Contactless

![Cptr_TransactionNFC](https://user-images.githubusercontent.com/59020462/71239723-8ddc7500-2307-11ea-9f07-2f4b11b42620.jpeg)

### 4. Prerequisites

The `Deployment Target` of the SDK is `iOS 10.0`.  
Your Xcode project deployment target must be iOS 10.0 of later.

### 5. Dependency

The SDK is in the format `.framework`. You have to copy-paste it in your Xcode project. So if you want to use his public APIs you will need to import it:
```swift
import UCube
```

### 6. UCubeAPI

The APIs provided by UCubeAPI are:

```swift
setConnexionManager(_ connexionManager: ConnexionManager)  

setupLogger(_ logger: Loggable)  

pay(paymentRequest: UCubePaymentRequest,  
    didProgress: ProgressClosure? = nil,  
    didFinish: FinishClosure? = nil)  

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
    func getDevice() -> UCubeDevice?
    func connect(completion: @escaping ConnectionCompletion)
    func disconnect(completion: @escaping DisconnectionCompletion)
    func send(_ data: Data, completion: @escaping SendCommandCompletion)
}
```

* First you should set the connection manager to the SDK using `setConnectionManager` API. 

```swift  
let connectionManager = BLEConnectionManager()  
UCubeAPI.setConnectionManager(connectionManager)
```
`BLEConnectionManager` conforms to ConnectionManager protocol.

* Second you should set `Privacy - Bluetooth Always Usage Description` in Info.plist if you want to do a BLE scan.

* Third you should select the device that you want to communicate with.
  * `BLEConnectionManager` provides a `public func startScan()` & `public func stopScan()` methods which allow you to start and stop LE scan. In the SampleApp an example of device selection using these methods is provided.
  * `BLEConnectionManager` also provides a `scanDelegate` property in order to send scan events. You need to conform to `ScanDelegate` protocol.

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

	private      var applications: [EMVApplicationDescriptor]?
	private(set) var candidates: [EMVApplicationDescriptor]?
	private(set) var paymentContext: PaymentContext?

	public func setAvailableApplications(_ applications: [EMVApplicationDescriptor]) {
		self.applications = applications;
	}

	public func setPaymentContext(_ paymentContext: PaymentContext) {
		self.paymentContect = paymentContext;
	}

	@Override
	public func execute(monitor: TaskMonitoring) {
		var candidates: [EMVApplicationDescriptor] = []

		// Todo do AID selection

		monitor?.eventHandler(.success) // should call this to return to the payment state machine
	}

}
```

#### RiskManagementTasking
 ```swift
public class RiskManagementTask: RiskManagementTasking {
	private(set)  var paymentContext: PaymentContext?
	private(set)  var tvr: Data?

	public func setPaymentContext(_ paymentContext: PaymentContext) {
		self.paymentContext = paymentContext;
	}

	public func execute(monitor: TaskMonitoring) {
		self.monitor = monitor

		//TODO perform risk management 
		
		monitor?.eventHandler(.success); // should call this to return to the payment state machine
	}
}
```
#### AuthorizationTasking
```swift
public class AuthorizationTask: AuthorizationTasking {

  private(set) var authorizationResponse: Data?
  private(set) var paymentContext: PaymentContext?

	public func setPaymentContext(_ paymentContext: PaymentContext) {
		self.paymentContext = paymentContext;
	}

	public func execute(monitor: TaskMonitoring) {
		self.monitor = monitor

		//TODO perform risk management 
		
		monitor?.eventHandler(.success); // should call this to return to the payment state machine
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
  let readers = [
    RPC.Reader.icc,
    RPC.Reader.nfc
  ]

  let paymentRequest = UCubePaymentRequest()
	.setAmount(15.0)
	.setCurrency(UCubePaymentRequest.Currency.eur) // Indicates the currency code of the transaction according to ISO 4217
	.setTransactionType(trxType)
	.setTransactionDate(Date())
	.setCardWaitTimeout(timeout)
	.setDisplayResult(true) // at the end of transaction is the SDK display the payment result on uCube or just return the result
	.setReaderList(readers) // the list of reader interfaces to activate when start the payment
	.setForceOnlinePin(true) // Applicable for NFC and MSR
	.setForceAuthorisation(true) 
	.setRequestedAuthorizationTags(RPC.Tag.tvr, RPC.Tag.tsi)
	.setRequestedSecuredTags(RPC.Tag.track2EquData)
	.setRequestedPlainTags(RPC.Tag.msrBin)
	.setApplicationSelectionTask(ApplicationSelectionTask()) // if not set the SDK use the EMV default selection
	.setAuthorizationTask(AuthorizationTask()) //Mandatory
	.setRiskManagementTask(RiskManagementTask()) // Mandatory
	.setSystemFailureInfo(true) // get the transaction level 1 Logs
	.setSystemFailureInfo2(true) // get the transaction level 2 Logs
	.setPreferredLanguages(["en"]) // each language represented by 2 alphabetical characters according to ISO 639
```

#### Pay
```swift
UCubeAPI.pay(
  paymentRequest: paymentRequest,
  didProgress: { state: ServiceState in
    // your code here
  },
  didFinish: { success: Bool in
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
GetInfosCommand.swift
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
