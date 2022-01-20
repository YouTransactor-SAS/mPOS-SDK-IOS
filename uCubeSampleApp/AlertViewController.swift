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

import UIKit

struct AlertAction {
    
    let title: String
    let handler: (() -> Void)?
    let autoDismiss: Bool
    
    init(title: String, handler: (() -> Void)? = nil, autoDismiss: Bool = true) {
        self.title = title
        self.handler = handler
        self.autoDismiss = autoDismiss
    }
}

class AlertViewController: UIViewController {

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var actionsStackView: UIStackView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleStackView: UIStackView!
    @IBOutlet weak var messageStackView: UIStackView!
    @IBOutlet weak var actionsContainerStackView: UIStackView!
    
    var alertTitle: String? {
        didSet {
            setupTitle()
        }
    }
    var alertMessage: String? {
        didSet {
            setupMessage()
        }
    }
    var actions: [AlertAction]? {
        didSet {
            setupActions()
        }
    }
    
    static func initWithStoryboard() -> AlertViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! AlertViewController
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTitle()
        setupMessage()
        setupActions()
    }
    
    func update(title: String? = nil, message: String? = nil, actions: [AlertAction]? = nil) {
        self.alertTitle = title
        self.alertMessage = message
        self.actions = actions
    }
    
    private func setupTitle() {
        guard titleStackView != nil else { return }
        titleLabel.text = alertTitle
        titleStackView.isHidden = alertTitle == nil
    }
    
    private func setupMessage() {
        guard messageStackView != nil else { return }
        messageLabel.text = alertMessage
        messageStackView.isHidden = alertMessage == nil
    }
    
    private func setupActions() {
        guard actionsStackView != nil else { return }
        actionsContainerStackView.isHidden = actions == nil
        for subview in actionsStackView.arrangedSubviews {
            actionsStackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
        guard let actions = actions else { return }
        for i in 0..<actions.count {
            let button = UIButton(type: .system)
            button.setTitle(actions[i].title, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
            button.tag = i
            button.addTarget(self, action: #selector(didTapButton(sender:)), for: .touchUpInside)
            actionsStackView.addArrangedSubview(button)
        }
        if actions.count > 2 {
            actionsStackView.axis = .vertical
            actionsStackView.spacing = 12
        } else {
            actionsStackView.axis = .horizontal
            actionsStackView.spacing = 0
        }
    }
    
    @objc
    func didTapButton(sender: UIButton) {
        let action = actions?[sender.tag]
        action?.handler?()
        if action?.autoDismiss ?? true {
            dismiss(animated: false)
        }
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
