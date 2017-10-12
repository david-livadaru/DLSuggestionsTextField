//
//  PhonesSuggestionsHandler.swift
//  DLSuggestionsTextFieldDemo
//
//  Created by David Livadaru on 13/08/16.
//  Copyright © 2016 Community. All rights reserved.
//

import UIKit
import DLSuggestionsTextField

class PhonesSuggestionsHandler: NSObject {
    let storage = Storage()
    
    fileprivate (set) var phones: [Phone] = []
    
    static let kTableViewCellReuseIdentifier = "\(String(describing: PhonesSuggestionsHandler.self)).\(String(describing: UITableViewCell.self))"
    
    override init() {
        phones = storage.phones
        super.init()
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

extension PhonesSuggestionsHandler : SuggestionsTextFieldConfigurationDelegate {
    func suggestionsTextFieldDidChangeText(textField: SuggestionsTextField, completion: @escaping () -> Void) {
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
        
        completion()
    }
}
