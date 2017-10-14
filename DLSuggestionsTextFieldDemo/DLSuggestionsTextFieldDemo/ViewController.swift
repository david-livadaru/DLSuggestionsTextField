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

class ViewController: UIViewController, PhonesSuggestionsHandlerObserver {
    @IBOutlet weak var suggestionsTextField: TextField!
    
    private let suggestionsHandler = PhonesSuggestionsHandler()
    private let suggestionsTableView = TableView()
    private let suggestionsLabel = UILabel()
    
    private var placeholderAttributes: [NSAttributedStringKey : Any] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        suggestionsHandler.observer = self
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
        suggestionsTextField.suggestionTextSpacing = -3

        suggestionsTextField.suggestionLabel = suggestionsLabel
        suggestionsTextField.suggestionsContentView = suggestionsTableView

        NotificationCenter.default.addObserver(suggestionsHandler,
                                               selector: #selector(PhonesSuggestionsHandler.textFieldDidChangeText(_:)),
                                               name: .UITextFieldTextDidChange, object: suggestionsTextField)
    }

    deinit {
        NotificationCenter.default.removeObserver(suggestionsHandler)
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

    // MARK: PhonesSuggestionsHandlerObserver

    func handlerDidUpdatePhones(handler: PhonesSuggestionsHandler) {
        updateSuggestionLabel()
        suggestionsTableView.reloadData()
    }

    private func updateSuggestionLabel() {
        var suggestionText = ""
        if let phone = self.suggestionsHandler.phones.first,
            let text = self.suggestionsTextField.text, text.count > 0,
            phone.name.hasPrefix(text) {
            let substringIndex = phone.name.characters.index(phone.name.startIndex,
                                                             offsetBy: text.characters.count)
            suggestionText = String(phone.name[substringIndex..<phone.name.endIndex])
            
        }
        self.suggestionsLabel.attributedText = NSAttributedString(string: suggestionText,
                                                                  attributes: self.placeholderAttributes)
    }
    
    // MARK: Private
    
    fileprivate func selectPhone(atIndex index: Int) {
        guard index < suggestionsHandler.phones.count else { return }
        
        let phone = suggestionsHandler.phones[index]
        suggestionsTextField.text = phone.name
    }
}

extension ViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectPhone(atIndex: indexPath.row)
        suggestionsTextField.resignFirstResponder()
    }
}

extension ViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let text = textField.text, text.count > 0 {
            selectPhone(atIndex: 0)
        }
        return false
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text, text.count > 0 {
            selectPhone(atIndex: 0)
        }
    }
}

class TableView: UITableView {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let isPointInside = super.point(inside: point, with: event)

        if isPointInside {
            for cell in visibleCells where cell.frame.contains(point) {
                return true
            }
        }
        return false
    }
}
