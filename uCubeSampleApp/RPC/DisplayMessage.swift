/*============================================================================

* Copyright © 2022 YouTransactor.
* All Rights Reserved.
*
* This software is the confidential and proprietary information of YouTransactor
* ("Confidential Information"). You  shall not disclose or redistribute such
* Confidential Information and shall use it only in accordance with the terms of
* the license agreement you entered into with YouTransactor.
*
* This software is provided by YouTransactor AS IS, and YouTransactor
* makes no representations or warranties about the suitability of the software,
* either express or implied, including but not limited to the implied warranties
* of merchantability, fitness for a particular purpose or non-infringement.
* YouTransactor shall not be liable for any direct, indirect, incidental,
* special, exemplary, or consequential damages suffered by licensee as the
* result of using, modifying or distributing this software or its derivatives.
*
*==========================================================================*/

import UCube

struct DisplayMessage {
    
    func display(_ message: String, completion: @escaping (_ success: Bool, _ message: String?) -> Void) {
        let command = DisplayMessageCommand(message: message)
        command.setClearConfig(5)
        command.setTimeout(2)
        command.setXPosition(0xFF)
        command.setYPosition(0x00)
        command.execute(monitor: TaskMonitor(eventHandler: { (event: TaskEvent, parameters: [Any]) in
            switch event {
            case .failed:
                 LogManager.debug(message: "Displaying \(message) failed")
                 completion(false, "Command failed")
            case .cancelled:
                 LogManager.debug(message: "Displaying \(message) cancelled")
                 completion(false, "Command cancelled")
            case .success:
                LogManager.debug(message: "Displaying \(message) succeeded")
                completion(true, "Command succeeded")
            default:
                break
            }
        }))
    }
}
