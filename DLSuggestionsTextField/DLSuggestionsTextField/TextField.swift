//
//  TextField.swift
//  DLSuggestionsTextField
//
//  Created by David Livadaru on 08/07/16.
//  Copyright © 2016 Community. All rights reserved.
//

import UIKit

// MARK: - SuggestionsTextField
@IBDesignable open class TextField: UITextField {
    public typealias LabelViewType = UIView & LabelView
    public typealias ContentViewType = UIView & ContentView

    open override var text: String? {
        didSet {
            NotificationCenter.default.post(name: .UITextFieldTextDidChange, object: self)
        }
    }

    /// Adjusts vertical text insets.
    @IBInspectable open var verticalTextInsets: CGPoint = CGPoint.zero {
        didSet {
            setNeedsLayout()
        }
    }
    /// Adjusts horizontal text insets.
    @IBInspectable open var horizontalTextInsets: CGPoint = CGPoint.zero {
        didSet {
            setNeedsLayout()
        }
    }

    /// The minimum width required for suggestion text in order to be legible. Default is 24 points.
    @IBInspectable open var minSuggestionTextWidth: CGFloat = 24 {
        didSet {
            setNeedsLayout()
        }
    }
    /// The space between typing text and suggestion text
    @IBInspectable open var suggestionTextSpacing: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    /// the minimum width required for text to be visible. Default is 10 points.
    @IBInspectable open var minEditingTextWidth: CGFloat = 10 {
        didSet {
            setNeedsLayout()
        }
    }

    /// Text insets created from vertical and horizontal insets.
    open var textInsets: UIEdgeInsets {
        return UIEdgeInsets(top: verticalTextInsets.x, left: horizontalTextInsets.x,
                            bottom: verticalTextInsets.y, right: horizontalTextInsets.y)
    }

    /// The label which displays the proposed suggestion or the remaining text of suggestion.
    open var suggestionLabel: LabelViewType?
    /// Content view which displays the list of suggestions.
    open var suggestionsContentView: ContentViewType?

    /// The view where content view will be placed. If this property is nil, the visible window will be used.
    public private (set) var contentViewContainer: UIView?

    open var layoutController: LayoutController!
    open var animationController: AnimationController!

    var containsText: Bool {
        guard let attributedText = attributedText else { return false }
        return attributedText.string.characters.count > 0
    }

    // MARK: Life Cycle

    override public init(frame: CGRect) {
        super.init(frame: frame)

        initializeView()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        initializeView()
    }

    /// Set a container view where the content view will be placed.
    ///
    /// - Parameter contentViewContainer: the container view.
    public func setContentViewContainer(_ contentViewContainer: UIView) {
        self.contentViewContainer = contentViewContainer
    }

    public func addLabelViewToViewHierarchy() {
        if let textView = suggestionLabel {
            addSubview(textView)
        }
    }

    public func removeLabelViewToViewHierarchy() {
        suggestionLabel?.removeFromSuperview()
    }

    public func addContentViewToViewHierarchy() {
        guard let contentView = suggestionsContentView else { return }

        let container = contentViewContainer ?? UIApplication.shared.keyWindow
        container?.addSubview(contentView)
    }

    public func removeContentViewToViewHierarchy() {
        suggestionsContentView?.removeFromSuperview()
    }

    // MARK: Override

    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        let textRect = super.textRect(forBounds: bounds)
        return layoutController?.textRect(forBounds: textRect) ?? textRect
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        let placeholderRect = super.placeholderRect(forBounds: bounds)
        return layoutController?.editingRect(forBounds: placeholderRect) ?? placeholderRect
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        let editingRect = super.editingRect(forBounds: bounds)
        return layoutController?.editingRect(forBounds: editingRect) ?? editingRect
    }

    override open func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        let clearButtonRect = super.clearButtonRect(forBounds: bounds)
        return layoutController?.clearButtonRect(forBounds: clearButtonRect) ?? clearButtonRect
    }

    override open func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        let leftViewRect = super.leftViewRect(forBounds: bounds)
        return layoutController?.leftViewRect(forBounds: leftViewRect) ?? leftViewRect
    }

    override open func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        let rightViewRect = super.rightViewRect(forBounds: bounds)
        return layoutController?.rightViewRect(forBounds: rightViewRect) ?? rightViewRect
    }

    // MARK: Private interface

    private func initializeView() {
        layoutController = LayoutController(textField: self)
        animationController = AnimationController(textField: self)
    }
}
