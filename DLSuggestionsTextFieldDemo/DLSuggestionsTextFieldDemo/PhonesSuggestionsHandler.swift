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
    
    private (set) var phones: [Phone] = []
    
    static let kTableViewCellReuseIdentifier = "\(String(PhonesSuggestionsHandler)).\(String(UITableViewCell))"
    
    override init() {
        phones = storage.phones
        super.init()
    }
}

extension PhonesSuggestionsHandler : UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return phones.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(PhonesSuggestionsHandler.kTableViewCellReuseIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: PhonesSuggestionsHandler.kTableViewCellReuseIdentifier)
        }
        
        let phone = phones[indexPath.row]
        cell?.textLabel?.text = phone.name
        cell?.detailTextLabel?.text = "\(phone.lastestSupportedOS.name) - \(phone.year)"
        
        return cell!
    }
}

extension PhonesSuggestionsHandler : SuggestionsTextFieldConfigurationDelegate {
    func suggestionsTextFieldDidChangeText(textField: SuggestionsTextField, completion: () -> Void) {
        if textField.text?.characters.count > 0, let text = textField.text {
            phones = storage.phones.filter({ (phone) -> Bool in
                let yearString = "\(phone.year)"
                return phone.name.containsString(text) ||
                    phone.lastestSupportedOS.name.containsString(text) ||
                    yearString.hasPrefix(text)
            })
        } else {
            phones = storage.phones
        }
        
        completion()
    }
}
