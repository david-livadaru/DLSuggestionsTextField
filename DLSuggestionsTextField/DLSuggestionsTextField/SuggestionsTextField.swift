//
//  SuggestionsTextField.swift
//  DLSuggestionsTextField
//
//  Created by David Livadaru on 08/07/16.
//  Copyright © 2016 Community. All rights reserved.
//

import UIKit


@objc public protocol SuggestionsTextFieldConfigurationDelegate : class {
    /**
     Customization point after textField started editing.
     At this point, the suggestions content view should pe prepared for display and
     added to the view hierarchy if addContentViewOnWindow is set to false.
     
     - parameter textField:         textField which called the delegate.
     - parameter contentViewTraits: proposed content view traits.
     - parameter contentView:       content view on which traits should be applied.
     */
    optional func suggestionsTextField(textField: SuggestionsTextField,
                                       proposedContentViewTraits contentViewTraits: SuggestionsContentViewTraits,
                                       forSuggestionContentView contentView: SuggestionsContentViewType?)
    /**
     Customization point when keyboard changes the frame.
     View hierarchy needs to redo layout in order to adjust content shown to user
     to fit with the present keyboard.
     
     - parameter textField:               textField which called the delegate.
     - parameter contentViewTraits:       proposed content view traits.
     - parameter contentView:             content view on which traits should be applied.
     - parameter keyboardAnimationTraits: keyboard animation data.
     */
    optional func suggestionsTextField(textField: SuggestionsTextField,
                                       proposedContentViewTraits contentViewTraits: SuggestionsContentViewTraits,
                                       forSuggestionContentView contentView: SuggestionsContentViewType?,
                                       keyboardAnimationTraits: KeyboardAnimationTraits)
    /**
     Customization point after textField ended editing.
     This might be an event where the content view should be hidden.
     At the end completion should called.
     
     - parameter textField:   textField which called the delegate.
     - parameter contentView: content view which will be hidden.
     - parameter completion:  closure which removes content view from view hierarchy.
     */
    optional func suggestionsTextField(textField: SuggestionsTextField,
                                       hideSuggestionsContentView contentView: SuggestionsContentViewType?,
                                       completion: () -> Void)
    /**
     Asks the delegate if forced layout can be done in order to compute proposed frame.
     If the content view uses self-sizing cells the forced layout may become an expensive operation.
     
     - parameter textField:   textField which called the delegate.
     - parameter contentView: content view on which the layout will be forced.
     
     - returns: Returns false if layout should not be forced.
     */
    optional func suggestionsTextField(textField: SuggestionsTextField,
                                       shouldPerformLayoutOnFrameComputationFor contentView: SuggestionsContentViewType?) -> Bool
    /**
     Informs the delegate that text from textField did change.
     At this point the data source of content view might be filetered,
     suggestionTextView is updated with new text,
     contentView's data is updated.
     
     - parameter textField:  textField which called the delegate.
     - parameter completion: closure which reloads content of contentView.
     */
    optional func suggestionsTextFieldDidChangeText(textField: SuggestionsTextField, completion: () -> Void)
}

@objc public protocol SuggestionsTextFieldDataSource : class {
    /**
     Asks the data source to provide an instance of implemented SuggestionsContentViewType.
     By default UITableView and UICollectionView implements SuggestionsContentViewType.
     
     - parameter textField: textField which called the data source.
     
     - returns: An instance of SuggestionsContentViewType.
     */
    func suggestionsTextFieldSuggestionsContentView(textField: SuggestionsTextField) -> SuggestionsContentViewType
    /**
     Asks the data source to provide an instance of implemented SuggestionTextViewType.
     By default UILabel implements SuggestionTextViewType.
     
     - parameter textField: textField which called the data source.
     
     - returns: An instance of SuggestionTextViewType.
     */
    optional func suggestionsTextFieldSuggestionTextView(textField: SuggestionsTextField) -> SuggestionTextViewType
}

@IBDesignable
public class SuggestionsTextField: UITextField {
    /// Adjusts vertical text insets.
    @IBInspectable public var verticalTextInsets: CGPoint = CGPoint.zero {
        didSet {
            setNeedsLayout()
        }
    }
    /// Adjusts horizontal text insets.
    @IBInspectable public var horizontalTextInsets: CGPoint = CGPoint.zero {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// Delegate which is reponsible with content view management and configuration of SuggestionsTextField.
    weak public var configurationDelegate: SuggestionsTextFieldConfigurationDelegate?
    /// Data source which provides a content view and optionally a text view for proposed suggestion.
    weak public var dataSource: SuggestionsTextFieldDataSource?
    
    /// The minimum width required for suggestion text in order to be legible. Default is 24 points.
    public var minSuggestionTextWidth: CGFloat = 24 {
        didSet {
            setNeedsLayout()
        }
    }
    /// the minimum width required for text to be visible. Default is 10 points.
    public var minEditingTextWidth: CGFloat = 10 {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// A boolean which indicates if content view should be added to the window. True by default.
    public var addContentViewOnWindow = true
    
    /// Text view which might display proposed suggestion or the remaining text of suggestion.
    private (set) var suggestionTextView: SuggestionTextViewType?
    /// Content view which displays the list of suggestions.
    private (set) var suggestionsContentView: SuggestionsContentViewType?
    
    /// Text insets created from vertical and horizontal insets.
    public var textInsets: UIEdgeInsets {
        return UIEdgeInsets(top: verticalTextInsets.x, left: horizontalTextInsets.x,
                            bottom: verticalTextInsets.y, right: horizontalTextInsets.y)
    }
    
    private var keyboardFrame = CGRect.zero
    
    private var containsText: Bool {
        return attributedText?.string.characters.count > 0
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
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: Public Interface
    
    public func prepareForDisplay() {
        suggestionTextView = dataSource?.suggestionsTextFieldSuggestionTextView?(self)
        suggestionsContentView = dataSource?.suggestionsTextFieldSuggestionsContentView(self)
    }

    public func hideSuggestionsContentView() {
        suggestionsContentView?.removeFromSuperViewType()
    }
    
    // MARK: UITextField Layout
    
    public func UITextFieldTextRectForBounds(bounds: CGRect) -> CGRect {
        return super.textRectForBounds(bounds)
    }
    
    public func UITextFieldEditingRectForBounds(bounds: CGRect) -> CGRect {
        return super.editingRectForBounds(bounds)
    }
    
    // MARK: Override
    
    override public func textRectForBounds(bounds: CGRect) -> CGRect {
        var textRect = super.textRectForBounds(bounds)
        textRect.insetInPlace(textInsets)
        
        return textRect
    }
    
    public override func editingRectForBounds(bounds: CGRect) -> CGRect {
        var availableTextRect = super.editingRectForBounds(bounds)
        
        availableTextRect.insetInPlace(textInsets)
        
        var textRect = availableTextRect
        var requiredLabelSize = suggestionTextView?.systemLayoutSizeFittingSize(availableTextRect.size) ?? CGSize.zero
        requiredLabelSize.ceilInPlace()
        
        var requiredTextRect = CGRect.zero
        if containsText {
            requiredTextRect = attributedText?.boundingRectWithSize(availableTextRect.size, options: .UsesLineFragmentOrigin, context: nil) ?? CGRect.zero
        } else {
            requiredTextRect = attributedPlaceholder?.boundingRectWithSize(availableTextRect.size, options: .UsesLineFragmentOrigin, context: nil) ?? CGRect.zero
        }
        requiredTextRect.ceilInPlace()
        
        if text?.characters.count > 0 { // the offset is required due to the way text scroll from UITextField works
            requiredTextRect.size.width += minEditingTextWidth
        }
        
        let availableWidth = max(0, availableTextRect.width - requiredTextRect.width)
        let labelWidth = max(minSuggestionTextWidth, availableWidth)
        
        if let suggestionTextView = self.suggestionTextView where containsText {
            var labelFrame = CGRect.zero
            labelFrame.origin.x = availableTextRect.maxX - labelWidth
            labelFrame.origin.y = floor((bounds.height - requiredLabelSize.height) / 2)
            labelFrame.size.width = labelWidth
            labelFrame.size.height = requiredLabelSize.height
            
            suggestionTextView.frame = labelFrame
        }
        
        if containsText {
            showSuggestionTextView()
        } else {
            hideSuggestionTextView()
        }
        
        textRect.size.width -= labelWidth
        
        return textRect
    }
    
    // MARK: Notifications
    
    @objc private func didBeginEditing() {
        var frame = computeSuggestionsContentViewFrame()
        let contentViewTraits = SuggestionsContentViewTraits(frame: frame)
        frame.size.height = 0
        suggestionsContentView?.frame = frame
        if addContentViewOnWindow, let window = UIApplication.sharedApplication().delegate?.window,
            let contentView = suggestionsContentView {
            window?.addSubviewType(contentView)
        }
        configurationDelegate?.suggestionsTextField?(self, proposedContentViewTraits: contentViewTraits,
                                                     forSuggestionContentView: suggestionsContentView)
    }
    
    @objc private func didEndEditing() {
        hideSuggestionTextView()
        
        configurationDelegate?.suggestionsTextField?(self, hideSuggestionsContentView: suggestionsContentView) {
            self.hideSuggestionsContentView()
        }
    }
    
    @objc private func didChangeText() {
        configurationDelegate?.suggestionsTextFieldDidChangeText?(self) {
            self.suggestionsContentView?.reloadData()
        }
    }
    
    @objc private func keyboardWillChangeFrame(notification: NSNotification) {
        guard let keyboardFrameValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue,
            let keyboardAnimationDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey],
            let keyboardAnimationCurve = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] else { return }

        keyboardFrame = keyboardFrameValue.CGRectValue()
        let keyboardAnimationTraits = KeyboardAnimationTraits(frame: keyboardFrame,
                                                              duration: keyboardAnimationDuration.doubleValue,
                                                              curve: keyboardAnimationCurve.unsignedIntegerValue)
        let contentViewTraits = SuggestionsContentViewTraits(frame: computeSuggestionsContentViewFrame())
        configurationDelegate?.suggestionsTextField?(self, proposedContentViewTraits: contentViewTraits,
                                                     forSuggestionContentView: suggestionsContentView,
                                                     keyboardAnimationTraits: keyboardAnimationTraits)
        
    }
    
    // MARK: Private
    
    private func registerToNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SuggestionsTextField.didBeginEditing),
                                                         name: UITextFieldTextDidBeginEditingNotification, object: self)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SuggestionsTextField.didEndEditing),
                                                         name: UITextFieldTextDidEndEditingNotification, object: self)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SuggestionsTextField.didChangeText),
                                                         name: UITextFieldTextDidChangeNotification, object: self)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SuggestionsTextField.keyboardWillChangeFrame(_:)),
                                                         name: UIKeyboardWillChangeFrameNotification, object: nil)
    }
    
    private func computeSuggestionsContentViewFrame() -> CGRect {
        var contentViewFrame = CGRect.zero
        
        if let nonNilSuperView = self.superview {
            let selfWindowFrame = nonNilSuperView.convertRect(frame, toView: nil)
            
            contentViewFrame.origin.x = selfWindowFrame.minX
            contentViewFrame.origin.y = selfWindowFrame.maxY
            contentViewFrame.size.width = selfWindowFrame.width
            
            var currentContentViewHeight = CGFloat.max
            let canPerformLayout = configurationDelegate?.suggestionsTextField?(self, shouldPerformLayoutOnFrameComputationFor: suggestionsContentView) ?? true
            if canPerformLayout {
                suggestionsContentView?.layoutIfNeeded()
                currentContentViewHeight = suggestionsContentView?.contentSize.height ?? 0
            }
            let availableHeight = max(0, keyboardFrame.minY - selfWindowFrame.maxY)
            contentViewFrame.size.height = min(currentContentViewHeight, availableHeight)
        }
        
        return contentViewFrame
    }
    
    private func showSuggestionTextView() {
        if let textView = suggestionTextView {
            addSubviewType(textView)
        }
    }

    private func hideSuggestionTextView() {
        suggestionTextView?.removeFromSuperViewType()
    }
}
