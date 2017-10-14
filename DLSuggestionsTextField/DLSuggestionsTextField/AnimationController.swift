//
//  AnimationController.swift
//  DLSuggestionsTextField
//
//  Created by David Livadaru on 10/14/17.
//  Copyright © 2017 Community. All rights reserved.
//

import Foundation

open class AnimationController {
    unowned public let textField: TextField

    public init(textField: TextField) {
        self.textField = textField

        registerToNotifications()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    open func animateAppearanceOfSubviews(with traits: KeyboardAnimationTraits) {
        let labelView = textField.suggestionLabel
        let contentView = textField.suggestionsContentView

        labelView?.alpha = 0.0

        textField.addLabelViewToViewHierarchy()
        textField.addContentViewToViewHierarchy()

        let contentViewFinalFrame = textField.layoutController.suggestionsContentViewFrame()
        var contentViewInitialFrame = contentViewFinalFrame
        contentViewInitialFrame.size.height = 0.0

        contentView?.frame = contentViewInitialFrame

        UIView.animate(withDuration: traits.duration, delay: 0.0, options: traits.curve, animations: {
            labelView?.alpha = 1.0
            contentView?.frame = contentViewFinalFrame
        }, completion: nil)
    }

    open func animateDisppearanceOfSubviews(with traits: KeyboardAnimationTraits) {
        let labelView = textField.suggestionLabel
        let contentView = textField.suggestionsContentView

        var contentViewFinalFrame = textField.layoutController.suggestionsContentViewFrame()
        contentViewFinalFrame.size.height = 0.0

        UIView.animate(withDuration: traits.duration, delay: 0.0, options: traits.curve, animations: {
            labelView?.alpha = 0.0
            contentView?.frame = contentViewFinalFrame
        }, completion: { _ in
            self.textField.removeLabelViewToViewHierarchy()
            self.textField.removeContentViewToViewHierarchy()
        })
    }

    // MARK: Notifications

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let traits = KeyboardAnimationTraits(notification: notification) else { return }

        animateAppearanceOfSubviews(with: traits)
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let traits = KeyboardAnimationTraits(notification: notification) else { return }

        animateDisppearanceOfSubviews(with: traits)
    }

    // MARK: Private interface

    private func registerToNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)),
                                               name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)),
                                               name: .UIKeyboardWillHide, object: nil)
    }
}
