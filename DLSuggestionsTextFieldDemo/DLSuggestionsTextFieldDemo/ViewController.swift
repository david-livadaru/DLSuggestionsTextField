//
//  ViewController.swift
//  DLSuggestionsTextFieldDemo
//
//  Created by David Livadaru on 08/07/16.
//  Copyright © 2016 Community. All rights reserved.
//

import UIKit
import DLSuggestionsTextField

fileprivate extension Dictionary {
    typealias TransformClosure<NewKey, NewValue> = ((key: Key, value: Value)) -> (key: NewKey,
                                                                                  value: NewValue)
    func map<NewKey, NewValue>(_ transform: TransformClosure<NewKey, NewValue>) -> [NewKey: NewValue] {
        var newDictionary: [NewKey: NewValue] = [:]
        for key in keys {
            if let value = self[key] {
                let mappedPair = transform((key, value))
                newDictionary[mappedPair.key] = mappedPair.value
            }
        }
        return newDictionary
    }
}

class ViewController: UIViewController {
    @IBOutlet weak var suggestionsTextField: TextField!
    
    fileprivate let suggestionsHandler = PhonesSuggestionsHandler()
    fileprivate let suggestionsTableView = UITableView()
    fileprivate let suggestionsLabel = UILabel()
    
    fileprivate var placeholderAttributes: [NSAttributedStringKey : Any] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        suggestionsTableView.isHidden = true
        view.addSubview(suggestionsTableView)
        
        suggestionsTableView.dataSource = suggestionsHandler
        suggestionsTableView.delegate = self
        suggestionsTableView.tableFooterView = UIView()
        
        placeholderAttributes[NSAttributedStringKey.font] = UIFont(name: "Arial", size: 14)
        placeholderAttributes[NSAttributedStringKey.foregroundColor] = UIColor.lightGray
        var textAttributes = placeholderAttributes
        textAttributes[NSAttributedStringKey.foregroundColor] = UIColor.darkText
        suggestionsTextField.defaultTextAttributes = textAttributes.map({ (key: $0.key.rawValue, value: $0.value) })
        suggestionsTextField.attributedPlaceholder = NSAttributedString(string: "Search for a phone",
                                                                        attributes: placeholderAttributes)
        suggestionsTextField.configurationDelegate = self
        suggestionsTextField.suggestionTextSpacing = -3
        
        suggestionsTextField.setSuggestionTextView(textView: suggestionsLabel)
        suggestionsTextField.setSuggestionsContentView(contentView: suggestionsTableView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
    
    @IBAction func controllerViewTapped(_ sender: UITapGestureRecognizer) {
        if sender.state == .recognized {
            view.endEditing(true)
        }
    }
    
    // MARK: Private
    
    fileprivate func selectPhone(atIndex index: Int) {
        guard index < suggestionsHandler.phones.count else { return }
        
        let phone = suggestionsHandler.phones[index]
        suggestionsTextField.text = phone.name
    }
    
    fileprivate func filterSuggestions(_ completion: @escaping () -> Void) {
        suggestionsHandler.suggestionsTextFieldDidChangeText(textField: suggestionsTextField, completion: {
            var suggestionText = ""
            if let phone = self.suggestionsHandler.phones.first,
                let text = self.suggestionsTextField.text, phone.name.hasPrefix(text) {
                let substringIndex = phone.name.characters.index(phone.name.startIndex,
                                                                 offsetBy: text.characters.count)
                suggestionText = String(phone.name[substringIndex..<phone.name.endIndex])
                
            }
            self.suggestionsLabel.attributedText = NSAttributedString(string: suggestionText,
                attributes: self.placeholderAttributes)
            
            completion()
        })
    }
}

extension ViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        suggestionsTextField.resignFirstResponder()
        selectPhone(atIndex: indexPath.row)
        
        filterSuggestions { 
            tableView.reloadData()
        }
    }
}

extension ViewController : SuggestionsTextFieldConfigurationDelegate {
    func suggestionsTextField(textField: TextField,
                              proposedContentViewTraits contentViewTraits: ContentViewTraits,
                              keybordWillShowWith keyboardAnimationTraits: KeyboardAnimationTraits) {
        if suggestionsTableView.isHidden {
            suggestionsTableView.isHidden = false
        }
        
        var contentViewFrame = contentViewTraits.frame
        contentViewFrame.size.height = keyboardAnimationTraits.frame.minY - self.suggestionsTextField.frame.maxY
        
        var hiddenContentViewFrame = contentViewFrame
        hiddenContentViewFrame.size.height = 0
        
        suggestionsTableView.frame = hiddenContentViewFrame
        UIView.animate(withDuration: keyboardAnimationTraits.duration, delay: 0, options: keyboardAnimationTraits.curve,
                       animations: {
            self.suggestionsTableView.frame = contentViewFrame
        }, completion: nil)
    }
    
    func suggestionsTextField(textField: TextField,
                              keybordWillHideWith keyboardAnimationTraits: KeyboardAnimationTraits) {
        var hiddenContentViewFrame = suggestionsTableView.frame
        hiddenContentViewFrame.size.height = 0
        
        UIView.animate(withDuration: keyboardAnimationTraits.duration, delay: 0,options: keyboardAnimationTraits.curve,
                       animations: {
            textField.suggestionsContentView?.frame = hiddenContentViewFrame
        }) { (finished) in
            if keyboardAnimationTraits.isKeyboardHidden {
                textField.hideSuggestionsContentView()
            }
        }
    }
    
    func suggestionsTextFieldDidChangeText(textField: TextField, completion: @escaping () -> Void) {
        filterSuggestions(completion)
    }
}

extension ViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let text = textField.text, text.characters.count > 0 {
            selectPhone(atIndex: 0)
        }
        return false
    }
}
