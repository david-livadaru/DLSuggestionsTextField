//
//  ViewController.swift
//  DLSuggestionsTextFieldDemo
//
//  Created by David Livadaru on 08/07/16.
//  Copyright © 2016 Community. All rights reserved.
//

import UIKit
import DLSuggestionsTextField

class ViewController: UIViewController {
    @IBOutlet weak var suggestionsTextField: SuggestionsTextField!
    
    private let suggestionsHandler = PhonesSuggestionsHandler()
    private let suggestionsTableView = UITableView()
    private let suggestionsLabel = UILabel()
    
    private var placeholderAttributes: [String : AnyObject] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        suggestionsTableView.hidden = true
        view.addSubview(suggestionsTableView)
        
        suggestionsTableView.dataSource = suggestionsHandler
        suggestionsTableView.delegate = self
        suggestionsTableView.tableFooterView = UIView()
        
        placeholderAttributes[NSFontAttributeName] = UIFont(name: "Arial", size: 14)
        placeholderAttributes[NSForegroundColorAttributeName] = UIColor.lightGrayColor()
        var textAttributes = placeholderAttributes
        textAttributes[NSForegroundColorAttributeName] = UIColor.darkTextColor()
        suggestionsTextField.defaultTextAttributes = textAttributes
        suggestionsTextField.attributedPlaceholder = NSAttributedString(string: "Search for a phone",
                                                                        attributes: placeholderAttributes)
        suggestionsTextField.dataSource = self
        suggestionsTextField.configurationDelegate = self
        suggestionsTextField.suggestionTextSpacing = -3
        suggestionsTextField.prepareForDisplay()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    
        var tableViewFrame = CGRect.zero
        tableViewFrame.origin.x = suggestionsTextField.frame.minX
        tableViewFrame.origin.y = suggestionsTextField.frame.maxY
        tableViewFrame.size.width = suggestionsTextField.frame.width
        tableViewFrame.size.height = view.bounds.height - suggestionsTextField.frame.maxY
        suggestionsTableView.frame = tableViewFrame
        tableViewFrame.size.height = 0
        suggestionsTableView.frame = tableViewFrame
    }
    
    @IBAction func controllerViewTapped(sender: UITapGestureRecognizer) {
        if sender.state == .Recognized {
            view.endEditing(true)
        }
    }
    
    // MARK: Private
    
    private func selectPhone(atIndex index: Int) {
        guard index < suggestionsHandler.phones.count else { return }
        
        let phone = suggestionsHandler.phones[index]
        suggestionsTextField.text = phone.name
    }
    
    private func filterSuggestions(completion: (() -> Void)) {
        suggestionsHandler.suggestionsTextFieldDidChangeText(suggestionsTextField, completion: {
            var suggestionText = ""
            if let phone = self.suggestionsHandler.phones.first,
                let text = self.suggestionsTextField.text where phone.name.hasPrefix(text) {
                let substringIndex = phone.name.startIndex.advancedBy(text.characters.count)
                suggestionText = phone.name.substringFromIndex(substringIndex)
                
            }
            self.suggestionsLabel.attributedText = NSAttributedString(string: suggestionText,
                attributes: self.placeholderAttributes)
            
            completion()
        })
    }
}

extension ViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        suggestionsTextField.resignFirstResponder()
        selectPhone(atIndex: indexPath.row)
        
        filterSuggestions { 
            tableView.reloadData()
        }
    }
}

extension ViewController : SuggestionsTextFieldDataSource {
    func suggestionsTextFieldSuggestionsContentView(textField: SuggestionsTextField) -> SuggestionsContentViewType {
        return suggestionsTableView
    }
    
    func suggestionsTextFieldSuggestionTextView(textField: SuggestionsTextField) -> SuggestionTextViewType {
        return suggestionsLabel
    }
}

extension ViewController : SuggestionsTextFieldConfigurationDelegate {
    
    func suggestionsTextField(textField: SuggestionsTextField,
                              proposedContentViewTraits contentViewTraits: SuggestionsContentViewTraits,
                              keybordWillShowWith keyboardAnimationTraits: KeyboardAnimationTraits) {
        if suggestionsTableView.hidden {
            suggestionsTableView.hidden = false
        }
        
        var contentViewFrame = contentViewTraits.frame
        contentViewFrame.size.height = keyboardAnimationTraits.frame.minY - self.suggestionsTextField.frame.maxY
        
        var hiddenContentViewFrame = contentViewFrame
        hiddenContentViewFrame.size.height = 0
        
        suggestionsTableView.frame = hiddenContentViewFrame
        UIView.animateWithDuration(keyboardAnimationTraits.duration, delay: 0,
                                   options: UIViewAnimationOptions(rawValue: keyboardAnimationTraits.curve),
                                   animations: {
                                    self.suggestionsTableView.frame = contentViewFrame
        }, completion: nil)
    }
    
    func suggestionsTextField(textField: SuggestionsTextField,
                              keybordWillHideWith keyboardAnimationTraits: KeyboardAnimationTraits) {
        var hiddenContentViewFrame = suggestionsTableView.frame
        hiddenContentViewFrame.size.height = 0
        
        UIView.animateWithDuration(keyboardAnimationTraits.duration, delay: 0,
                                   options: UIViewAnimationOptions(rawValue: keyboardAnimationTraits.curve),
                                   animations: {
                                    textField.suggestionsContentView?.frame = hiddenContentViewFrame
        }) { (finished) in
            if keyboardAnimationTraits.isKeyboardHidden {
                textField.hideSuggestionsContentView()
            }
        }
    }
    
    func suggestionsTextFieldDidChangeText(textField: SuggestionsTextField, completion: () -> Void) {
        filterSuggestions(completion)
    }
}

extension ViewController : UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField.text?.characters.count > 0 {
            selectPhone(atIndex: 0)
        }
        return false
    }
}
