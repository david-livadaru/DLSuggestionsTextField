//
//  LayoutController.swift
//  DLSuggestionsTextField
//
//  Created by David Livadaru on 10/14/17.
//  Copyright © 2017 Community. All rights reserved.
//

import Foundation

open class LayoutController {
    unowned public let textField: TextField

    private var keyboardFrame = CGRect.zero

    public init(textField: TextField) {
        self.textField = textField

        registerToNotifications()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: UITextField computation

    open func borderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds
    }

    open func textRect(forBounds bounds: CGRect) -> CGRect {
        var textRect = bounds
        textRect.insetUsing(insets: textField.textInsets)
        return textRect
    }

    open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds
    }

    open func editingRect(forBounds bounds: CGRect) -> CGRect {
        var availableTextRect = bounds

        availableTextRect.insetUsing(insets: textField.textInsets)

        var textRect = availableTextRect

        var requiredTextRect = CGRect.zero
        let boundingRect: CGRect?
        if textField.containsText {
            boundingRect = textField.attributedText?.boundingRect(with: availableTextRect.size,
                                                                  options: .usesLineFragmentOrigin, context: nil)
        } else {
            boundingRect = textField.attributedPlaceholder?.boundingRect(with: availableTextRect.size,
                                                                         options: .usesLineFragmentOrigin, context: nil)
        }
        requiredTextRect = boundingRect ?? CGRect.zero
        requiredTextRect.ceil()

        if let text = textField.text, text.characters.count > 0 {
            // the offset is required due to the way text scroll from UITextField works
            requiredTextRect.size.width += textField.minEditingTextWidth
        }

        if let suggestionTextView = textField.suggestionLabel, textField.containsText {
            suggestionTextView.frame = suggestionLabelFrame(availableTextRect: availableTextRect,
                                                                requiredTextRect: requiredTextRect)
        }

        if textField.containsText {
            textField.showSuggestionTextView()
        } else {
            textField.hideSuggestionTextView()
        }

        if let suggestionTextView = textField.suggestionLabel,
            textField.containsText && suggestionTextView.frame.width != 0 {
            textRect.size.width -= textField.minSuggestionTextWidth + textField.suggestionTextSpacing
        }

        return textRect
    }

    open func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        return bounds
    }

    open func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        return bounds
    }

    open func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        return bounds
    }

    // MARK: TextField computation

    open func suggestionLabelFrame(availableTextRect: CGRect, requiredTextRect: CGRect) -> CGRect {
        guard let suggestionLabel = textField.suggestionLabel else { return CGRect.zero }

        var requiredLabelSize = suggestionLabel.systemLayoutSizeFitting(availableTextRect.size)
        requiredLabelSize.ceil()

        let availableWidth = max(0, availableTextRect.width - requiredTextRect.width)

        var labelWidth: CGFloat = 0
        if let attributedText = suggestionLabel.attributedText, attributedText.length > 0 {
            labelWidth = max(textField.minSuggestionTextWidth, availableWidth)
        }

        var labelFrame = CGRect.zero
        let spacing = textField.suggestionTextSpacing
        labelFrame.origin.x = min(requiredTextRect.width, availableTextRect.width - labelWidth) + spacing
        labelFrame.origin.y = floor((textField.bounds.height - requiredLabelSize.height) / 2)
        labelFrame.size.width = labelWidth
        labelFrame.size.height = requiredLabelSize.height

        return labelFrame
    }

    open func suggestionsContentViewFrame() -> CGRect {
        guard let superView = textField.superview else { return CGRect.zero }
        guard let contentView = textField.suggestionsContentView else { return CGRect.zero }

        let selfWindowFrame = superView.convert(textField.frame, to: nil)

        var contentViewFrame = CGRect.zero
        contentViewFrame.origin.x = selfWindowFrame.minX
        contentViewFrame.origin.y = selfWindowFrame.maxY
        contentViewFrame.size.width = selfWindowFrame.width

        var currentContentViewHeight = CGFloat.greatestFiniteMagnitude
        contentView.layoutIfNeeded()
        currentContentViewHeight = contentView.contentSize.height
        let availableHeight = max(0, keyboardFrame.minY - selfWindowFrame.maxY)
        contentViewFrame.size.height = min(currentContentViewHeight, availableHeight)

        return contentViewFrame
    }

    // MARK: Notifications

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let traits = KeyboardAnimationTraits(notification: notification) else { return }

        keyboardFrame = traits.frame
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let traits = KeyboardAnimationTraits(notification: notification) else { return }

        keyboardFrame = traits.frame
    }

    // MARK: Private interface

    private func registerToNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)),
                                               name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)),
                                               name: .UIKeyboardWillHide, object: nil)
    }
}
