//
//  SuggestionsTextField.swift
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
    @objc optional func suggestionsTextField(textField: SuggestionsTextField,
                                             proposedContentViewTraits contentViewTraits: SuggestionsContentViewTraits) -> CGRect
    /**
     Customization point before keyboard will show.
     View hierarchy needs to redo layout in order to adjust content shown to user
     to fit with the present keyboard.
     
     - parameter textField:               textField which called the delegate.
     - parameter contentViewTraits:       proposed content view traits.
     - parameter keyboardAnimationTraits: keyboard animation data.
     */
    @objc optional func suggestionsTextField(textField: SuggestionsTextField,
                                       proposedContentViewTraits contentViewTraits: SuggestionsContentViewTraits,
                                       keybordWillShowWith keyboardAnimationTraits: KeyboardAnimationTraits)
    
    /**
     Customization point before keyboard will hide.
     View hierarchy needs to redo layout in order to adjust content shown to user
     to fit with the keyboard dismissed.
     
     - parameter textField:               textField which called the delegate.
     - parameter keyboardAnimationTraits: keyboard animation data.
     */
    @objc optional func suggestionsTextField(textField: SuggestionsTextField,
                                       keybordWillHideWith keyboardAnimationTraits: KeyboardAnimationTraits)
    
    /**
     Customization point after textField ended editing.
     This might be an event where the content view should be hidden.
     At the end completion should called.
     
     - parameter textField:   textField which called the delegate.
     - parameter completion:  closure which removes content view from view hierarchy.
     */
    @objc optional func suggestionsTextField(textField: SuggestionsTextField,
                                       hideSuggestionsContentView contentView: SuggestionsContentViewType?,
                                       completion: () -> Void)
    /**
     Asks the delegate if forced layout can be done in order to compute proposed frame.
     If the content view uses self-sizing cells the forced layout may become an expensive operation.
     
     - parameter textField:   textField which called the delegate.
     
     - returns: Returns false if layout should not be forced.
     */
    @objc optional func suggestionsTextFieldShouldPerformLayoutOnFrameComputationForContentView(textField: SuggestionsTextField) -> Bool
    /**
     Informs the delegate that text from textField did change.
     At this point the data source of content view might be filetered,
     suggestionTextView is updated with new text,
     contentView's data is updated.
     
     - parameter textField:  textField which called the delegate.
     - parameter completion: closure which reloads content of contentView.
     */
    @objc optional func suggestionsTextFieldDidChangeText(textField: SuggestionsTextField,
                                                          completion: @escaping () -> Void)
}

// MARK: - SuggestionsTextField
@IBDesignable open class SuggestionsTextField: UITextField {
    public typealias SuggestionTextView = UIView & SuggestionTextViewType
    public typealias SuggestionsContentView = UIView & SuggestionsContentViewType
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
    
    /// Delegate which is reponsible with content view management and configuration of SuggestionsTextField.
    weak open var configurationDelegate: SuggestionsTextFieldConfigurationDelegate?
    
    /// The minimum width required for suggestion text in order to be legible. Default is 24 points.
    open var minSuggestionTextWidth: CGFloat = 24 {
        didSet {
            setNeedsLayout()
        }
    }
    /// The space between typing text and suggestion text
    open var suggestionTextSpacing: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    /// the minimum width required for text to be visible. Default is 10 points.
    open var minEditingTextWidth: CGFloat = 10 {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// A boolean which indicates if content view should be added to the window. True by default.
    open var addContentViewOnWindow = true
    
    /// Text view which might display proposed suggestion or the remaining text of suggestion.
    open fileprivate (set) var suggestionTextView: SuggestionTextView?
    /// Content view which displays the list of suggestions.
    open fileprivate (set) var suggestionsContentView: SuggestionsContentView?
    
    /// Text insets created from vertical and horizontal insets.
    open var textInsets: UIEdgeInsets {
        return UIEdgeInsets(top: verticalTextInsets.x, left: horizontalTextInsets.x,
                            bottom: verticalTextInsets.y, right: horizontalTextInsets.y)
    }
    
    fileprivate var keyboardFrame = CGRect.zero
    
    fileprivate var containsText: Bool {
        guard let attributedText = attributedText else { return false }
        return attributedText.string.characters.count > 0
    }
    
    // MARK: Life Cycle
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        registerToNotifications()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        registerToNotifications()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Public Interface
    
    /// Sets the view which will be used to display the selected suggestion.
    ///
    /// - Parameter textView: the view which is used.
    open func setSuggestionTextView<TextView: SuggestionTextViewType>(textView: TextView) where TextView: UIView {
        suggestionTextView = textView
    }
    
    /// Sets the view which will be used to display the suggestions as a list.
    ///
    /// - Parameter contentView: the view which is used to display the list.
    open func setSuggestionsContentView<ContentView: SuggestionsContentViewType>(contentView: ContentView) where ContentView: UIView {
        suggestionsContentView = contentView
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
    
    // MARK: UITextField Layout
    
    /**
     Provides acces to frame returned by UITextField.
     */
    open func UITextFieldTextRectForBounds(_ bounds: CGRect) -> CGRect {
        return super.textRect(forBounds: bounds)
    }
    
    /**
     Provides acces to frame returned by UITextField.
     */
    open func UITextFieldEditingRectForBounds(_ bounds: CGRect) -> CGRect {
        return super.editingRect(forBounds: bounds)
    }
    
    open func suggestionsTextViewFrame(availableTextRect: CGRect,
                                                           requiredTextRect: CGRect) -> CGRect {
        var requiredLabelSize = suggestionTextView?.systemLayoutSizeFitting(availableTextRect.size) ?? CGSize.zero
        requiredLabelSize.ceilInPlace()
        
        let availableWidth = max(0, availableTextRect.width - requiredTextRect.width)
        
        var labelWidth: CGFloat = 0
        if let attributedText = suggestionTextView?.attributedText, attributedText.length > 0 {
            labelWidth = max(minSuggestionTextWidth, availableWidth)
        }
        
        var labelFrame = CGRect.zero
        labelFrame.origin.x = min(requiredTextRect.width, availableTextRect.width - labelWidth) + suggestionTextSpacing
        labelFrame.origin.y = floor((bounds.height - requiredLabelSize.height) / 2)
        labelFrame.size.width = labelWidth
        labelFrame.size.height = requiredLabelSize.height
        
        return labelFrame
    }
    
    // MARK: Override
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        var textRect = super.textRect(forBounds: bounds)
        textRect.insetUsing(insets: textInsets)
        
        return textRect
    }
    
    open override func editingRect(forBounds bounds: CGRect) -> CGRect {
        var availableTextRect = super.editingRect(forBounds: bounds)
        availableTextRect.insetUsing(insets: textInsets)
        
        var textRect = availableTextRect
        
        var requiredTextRect = CGRect.zero
        if containsText {
            requiredTextRect = attributedText?.boundingRect(with: availableTextRect.size, options: .usesLineFragmentOrigin, context: nil) ?? CGRect.zero
        } else {
            requiredTextRect = attributedPlaceholder?.boundingRect(with: availableTextRect.size, options: .usesLineFragmentOrigin, context: nil) ?? CGRect.zero
        }
        requiredTextRect.ceilInPlace()
        
        if let text = text, text.characters.count > 0 { // the offset is required due to the way text scroll from UITextField works
            requiredTextRect.size.width += minEditingTextWidth
        }
        
        if let suggestionTextView = self.suggestionTextView, containsText {
            suggestionTextView.frame = suggestionsTextViewFrame(availableTextRect: availableTextRect,
                                                                requiredTextRect: requiredTextRect)
        }
        
        if containsText {
            showSuggestionTextView()
        } else {
            hideSuggestionTextView()
        }
        
        if let suggestionTextView = self.suggestionTextView, containsText && suggestionTextView.frame.width != 0 {
            textRect.size.width -= minSuggestionTextWidth + suggestionTextSpacing
        }
        
        return textRect
    }
    
    // MARK: Notifications
    
    @objc fileprivate func didBeginEditing() {
        var frame = computeSuggestionsContentViewFrame()
        let contentViewTraits = SuggestionsContentViewTraits(frame: frame)
        frame.size.height = 0
        if let delegateFrame = configurationDelegate?.suggestionsTextField?(textField: self,
                                                                            proposedContentViewTraits: contentViewTraits) {
            suggestionsContentView?.frame = delegateFrame
        }
        showSuggestionsContentView()
    }
    
    @objc fileprivate func didEndEditing() {
        hideSuggestionTextView()
        
        configurationDelegate?.suggestionsTextField?(textField: self, hideSuggestionsContentView: suggestionsContentView) {
            self.hideSuggestionsContentView()
        }
    }
    
    @objc fileprivate func didChangeText() {
        configurationDelegate?.suggestionsTextFieldDidChangeText?(textField: self) {
            self.suggestionsContentView?.reloadData()
        }
    }
    
    @objc fileprivate func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrameValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue,
            let keyboardAnimationDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey],
            let keyboardAnimationCurve = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey]
            else { return }
        
        keyboardFrame = keyboardFrameValue.cgRectValue
        let keyboardAnimationTraits = KeyboardAnimationTraits(frame: keyboardFrame,
                                                              duration: (keyboardAnimationDuration as AnyObject).doubleValue,
                                                              curve: (keyboardAnimationCurve as AnyObject).uintValue)
        let contentViewTraits = SuggestionsContentViewTraits(frame: computeSuggestionsContentViewFrame())
        configurationDelegate?.suggestionsTextField?(textField: self,
                                                     proposedContentViewTraits: contentViewTraits,
                                                     keybordWillShowWith: keyboardAnimationTraits)
        
    }
    
    @objc fileprivate func keyboardWillHide(_ notification: Notification) {
        guard let keyboardFrameValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue,
            let keyboardAnimationDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey],
            let keyboardAnimationCurve = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey]
            else { return }
        
        keyboardFrame = keyboardFrameValue.cgRectValue
        let keyboardAnimationTraits = KeyboardAnimationTraits(frame: keyboardFrame,
                                                              duration: (keyboardAnimationDuration as AnyObject).doubleValue,
                                                              curve: (keyboardAnimationCurve as AnyObject).uintValue)
        configurationDelegate?.suggestionsTextField?(textField: self,
                                                     keybordWillHideWith: keyboardAnimationTraits)
        
    }
    
    // MARK: Private
    
    fileprivate func registerToNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(SuggestionsTextField.didBeginEditing),
                                                         name: NSNotification.Name.UITextFieldTextDidBeginEditing, object: self)
        NotificationCenter.default.addObserver(self, selector: #selector(SuggestionsTextField.didEndEditing),
                                                         name: NSNotification.Name.UITextFieldTextDidEndEditing, object: self)
        NotificationCenter.default.addObserver(self, selector: #selector(SuggestionsTextField.didChangeText),
                                                         name: NSNotification.Name.UITextFieldTextDidChange, object: self)
        NotificationCenter.default.addObserver(self, selector: #selector(SuggestionsTextField.keyboardWillShow(_:)),
                                                         name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SuggestionsTextField.keyboardWillHide(_:)),
                                                         name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    fileprivate func computeSuggestionsContentViewFrame() -> CGRect {
        var contentViewFrame = CGRect.zero
        
        if let nonNilSuperView = self.superview {
            let selfWindowFrame = nonNilSuperView.convert(frame, to: nil)
            
            contentViewFrame.origin.x = selfWindowFrame.minX
            contentViewFrame.origin.y = selfWindowFrame.maxY
            contentViewFrame.size.width = selfWindowFrame.width
            
            var currentContentViewHeight = CGFloat.greatestFiniteMagnitude
            let canPerformLayout = configurationDelegate?.suggestionsTextFieldShouldPerformLayoutOnFrameComputationForContentView?(textField: self) ?? true
            if canPerformLayout {
                suggestionsContentView?.layoutIfNeeded()
                currentContentViewHeight = suggestionsContentView?.contentSize.height ?? 0
            }
            let availableHeight = max(0, keyboardFrame.minY - selfWindowFrame.maxY)
            contentViewFrame.size.height = min(currentContentViewHeight, availableHeight)
        }
        
        return contentViewFrame
    }
    
    fileprivate func showSuggestionTextView() {
        if let textView = suggestionTextView {
            addSubview(textView)
        }
    }

    fileprivate func hideSuggestionTextView() {
        suggestionTextView?.removeFromSuperview()
    }
}
