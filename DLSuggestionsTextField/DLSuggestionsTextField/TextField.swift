//
//  TextField.swift
//  DLSuggestionsTextField
//
//  Created by David Livadaru on 08/07/16.
//  Copyright © 2016 Community. All rights reserved.
//

import UIKit

// MARK: - SuggestionsTextFieldConfigurationDelegate
@objc public protocol SuggestionsTextFieldConfigurationDelegate: class {
    /**
     Customization point after textField started editing.
     At this point, the suggestions content view should pe prepared for display and
     added to the view hierarchy if addContentViewOnWindow is set to false.
     
     - parameter textField:         textField which called the delegate.
     - parameter contentViewTraits: proposed content view traits.
     */
    @objc optional func suggestionsTextField(textField: TextField,
                                             proposedContentViewTraits contentViewTraits: ContentViewTraits) -> CGRect
    /**
     Customization point before keyboard will show.
     View hierarchy needs to redo layout in order to adjust content shown to user
     to fit with the present keyboard.
     
     - parameter textField:               textField which called the delegate.
     - parameter contentViewTraits:       proposed content view traits.
     - parameter keyboardAnimationTraits: keyboard animation data.
     */
    @objc optional func suggestionsTextField(textField: TextField,
                                       proposedContentViewTraits contentViewTraits: ContentViewTraits,
                                       keybordWillShowWith keyboardAnimationTraits: KeyboardAnimationTraits)

    /**
     Customization point before keyboard will hide.
     View hierarchy needs to redo layout in order to adjust content shown to user
     to fit with the keyboard dismissed.
     
     - parameter textField:               textField which called the delegate.
     - parameter keyboardAnimationTraits: keyboard animation data.
     */
    @objc optional func suggestionsTextField(textField: TextField,
                                       keybordWillHideWith keyboardAnimationTraits: KeyboardAnimationTraits)

    /**
     Customization point after textField ended editing.
     This might be an event where the content view should be hidden.
     At the end completion should called.
     
     - parameter textField:   textField which called the delegate.
     - parameter completion:  closure which removes content view from view hierarchy.
     */
    @objc optional func suggestionsTextField(textField: TextField,
                                       hideSuggestionsContentView contentView: ContentView?,
                                       completion: () -> Void)
    /**
     Asks the delegate if forced layout can be done in order to compute proposed frame.
     If the content view uses self-sizing cells the forced layout may become an expensive operation.
     
     - parameter textField:   textField which called the delegate.
     
     - returns: Returns false if layout should not be forced.
     */
    @objc optional func suggestionsTextFieldShouldPerformLayoutOnFrameComputationForContentView(textField: TextField) -> Bool
    /**
     Informs the delegate that text from textField did change.
     At this point the data source of content view might be filetered,
     suggestionTextView is updated with new text,
     contentView's data is updated.
     
     - parameter textField:  textField which called the delegate.
     - parameter completion: closure which reloads content of contentView.
     */
    @objc optional func suggestionsTextFieldDidChangeText(textField: TextField,
                                                          completion: @escaping () -> Void)
}

// MARK: - SuggestionsTextField
@IBDesignable open class TextField: UITextField {
    public typealias LabelViewType = UIView & LabelView
    public typealias ContentViewType = UIView & ContentView

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

    /// Delegate which is reponsible with content view management and configuration of SuggestionsTextField.
    weak open var configurationDelegate: SuggestionsTextFieldConfigurationDelegate?

    /// A boolean which indicates if content view should be added to the window. True by default.
    open var addContentViewOnWindow = true

    /// The label which displays the proposed suggestion or the remaining text of suggestion.
    open var suggestionLabel: LabelViewType?
    /// Content view which displays the list of suggestions.
    open var suggestionsContentView: ContentViewType?

    /// The view where content view will be placed. Default is the visible window.
    public private (set) var contentViewContainer: UIView?

    open var layoutController: LayoutController!

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

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    /// Set a container view where the content view will be placed.
    ///
    /// - Parameter contentViewContainer: the container view.
    public func setContentViewContainer(_ contentViewContainer: UIView) {
        self.contentViewContainer = contentViewContainer
    }

    /**
     Adds content view on application window if addContentViewOnWindow is true.
     */
    open func showSuggestionsContentView() {
        if addContentViewOnWindow, let window = UIApplication.shared.delegate?.window,
            let contentView = suggestionsContentView {
            window?.addSubview(contentView)
        }
    }

    /**
     Removes content view from view hierarchy.
     */
    open func hideSuggestionsContentView() {
        suggestionsContentView?.removeFromSuperview()
    }

    // MARK: Override

    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        let textRect = super.textRect(forBounds: bounds)
        return layoutController.textRect(forBounds: textRect)
    }

    open override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let editingRect = super.editingRect(forBounds: bounds)
        return layoutController.editingRect(forBounds: editingRect)
    }

    // MARK: Notifications

    @objc open func didBeginEditing() {
        var frame = layoutController.suggestionsContentViewFrame()
        let traits = ContentViewTraits(frame: frame)
        frame.size.height = 0
        if let delegateFrame = configurationDelegate?.suggestionsTextField?(textField: self,
                                                                            proposedContentViewTraits: traits) {
            suggestionsContentView?.frame = delegateFrame
        }
        showSuggestionsContentView()
    }

    @objc open func didEndEditing() {
        hideSuggestionTextView()

        configurationDelegate?.suggestionsTextField?(textField: self,
                                                     hideSuggestionsContentView: suggestionsContentView) {
            self.hideSuggestionsContentView()
        }
    }

    @objc open func didChangeText() {
        configurationDelegate?.suggestionsTextFieldDidChangeText?(textField: self) {
            self.suggestionsContentView?.reloadData()
        }
    }

    // MARK: Framework interface

    func showSuggestionTextView() {
        if let textView = suggestionLabel {
            addSubview(textView)
        }
    }

    func hideSuggestionTextView() {
        suggestionLabel?.removeFromSuperview()
    }

    // MARK: Private interface

    private func initializeView() {
        registerToNotifications()

        contentViewContainer = UIApplication.shared.keyWindow
        layoutController = LayoutController(textField: self)
    }

    private func registerToNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(didBeginEditing),
                                               name: .UITextFieldTextDidBeginEditing, object: self)
        NotificationCenter.default.addObserver(self, selector: #selector(didEndEditing),
                                               name: .UITextFieldTextDidEndEditing, object: self)
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeText),
                                               name: .UITextFieldTextDidChange, object: self)
    }
}
