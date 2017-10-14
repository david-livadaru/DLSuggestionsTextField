//
//  PhonesSuggestionsHandler.swift
//  DLSuggestionsTextFieldDemo
//
//  Created by David Livadaru on 13/08/16.
//  Copyright © 2016 Community. All rights reserved.
//

import UIKit
import DLSuggestionsTextField

protocol PhonesSuggestionsHandlerObserver: class {
    func handlerDidUpdatePhones(handler: PhonesSuggestionsHandler)
}

class PhonesSuggestionsHandler: NSObject {
    let storage = Storage()

    weak var observer: PhonesSuggestionsHandlerObserver?

    private var textField: UITextField? {
        didSet {
            NotificationCenter.default.removeObserver(self, name: .UITextFieldTextDidChange, object: oldValue)
            NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidChangeText(_:)),
                                                   name: .UITextFieldTextDidChange, object: textField)
        }
    }
    
    fileprivate (set) var phones: [Phone] = [] {
        didSet {
            observer?.handlerDidUpdatePhones(handler: self)
        }
    }
    
    static let kTableViewCellReuseIdentifier = "\(String(describing: PhonesSuggestionsHandler.self))"
    
    override init() {
        phones = storage.phones
        super.init()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func filterPhonesWithText(from textField: UITextField) {
        self.textField = textField
    }

    func updatePhoneFor(_ textField: TextField) {
        if let text = textField.text, text.characters.count > 0 {
            phones = storage.phones.filter({ (phone) -> Bool in
                let yearString = "\(phone.year)"
                return (phone.name.contains(text) ||
                    phone.lastestSupportedOS.name.contains(text) ||
                    yearString.hasPrefix(text))
            })
        } else {
            phones = storage.phones
        }
    }

    // MARK: Private actions

    @objc private func textFieldDidChangeText(_ notification: Notification) {
        guard let textField = notification.object as? TextField else { return }

        updatePhoneFor(textField)
    }
}

extension PhonesSuggestionsHandler : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return phones.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: PhonesSuggestionsHandler.kTableViewCellReuseIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: PhonesSuggestionsHandler.kTableViewCellReuseIdentifier)
        }
        
        let phone = phones[indexPath.row]
        cell?.textLabel?.text = phone.name
        cell?.detailTextLabel?.text = "\(phone.lastestSupportedOS.name) - \(phone.year)"
        
        return cell!
    }
}
