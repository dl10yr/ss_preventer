import UIKit

final class SsProtectionManager {
    private weak var protectedWindow: UIWindow?
    private var originalWindowSuperlayer: CALayer?
    private var secureTextField: UITextField?

    func enableProtection(for window: UIWindow?) {
        guard let window = window else { return }
        if protectedWindow === window, secureTextField != nil {
            return
        }

        disableProtection()

        guard let windowSuperlayer = window.layer.superlayer else { return }

        let textField = UITextField(frame: window.bounds)
        textField.isSecureTextEntry = true
        textField.backgroundColor = .clear
        textField.isUserInteractionEnabled = false
        textField.textColor = .clear
        textField.tintColor = .clear
        textField.text = " "
        textField.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        window.addSubview(textField)

        // Move the window layer into secure text field's render container.
        windowSuperlayer.addSublayer(textField.layer)
        textField.layer.sublayers?.last?.addSublayer(window.layer)

        protectedWindow = window
        originalWindowSuperlayer = windowSuperlayer
        secureTextField = textField
    }

    func disableProtection() {
        guard let textField = secureTextField else { return }

        if let window = protectedWindow, let originalWindowSuperlayer = originalWindowSuperlayer {
            originalWindowSuperlayer.addSublayer(window.layer)
        }

        textField.layer.removeFromSuperlayer()
        textField.removeFromSuperview()

        secureTextField = nil
        protectedWindow = nil
        originalWindowSuperlayer = nil
    }
}
