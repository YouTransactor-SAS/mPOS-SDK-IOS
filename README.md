# mPOS-SDK-IOS

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
