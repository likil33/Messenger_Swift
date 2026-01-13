//
//  KeyboardManager.swift
//  ChatBot_Sample
//
//  Created by Santhosh K on 12/01/26.
//

import Foundation
import UIKit

final class KeyboardManager {

    static let shared = KeyboardManager()

    var onKeyboardHeightChanged: ((CGFloat, Bool) -> Void)?

    private init() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardChanged),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardChanged),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    @objc private func keyboardChanged(_ notification: Notification) {
        guard let info = notification.userInfo,
              let rect = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

        let screenHeight = UIScreen.main.bounds.height
        let keyboardHeight = max(0, screenHeight - rect.origin.y)
        let isShowing = keyboardHeight > 0

        onKeyboardHeightChanged?(keyboardHeight, isShowing)
    }
}
