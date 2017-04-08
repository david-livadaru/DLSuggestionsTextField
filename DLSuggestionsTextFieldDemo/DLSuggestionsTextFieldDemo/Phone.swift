//
//  Phone.swift
//  DLSuggestionsTextFieldDemo
//
//  Created by David Livadaru on 13/08/16.
//  Copyright © 2016 Community. All rights reserved.
//

import Foundation

class OperatingSystem {
    let name: String
    let version: OperatingSystemVersion
    
    init(name: String = "iOS", version: OperatingSystemVersion = OperatingSystemVersion()) {
        self.name = name
        self.version = version
    }
}

class Phone {
    let name: String
    let lastestSupportedOS: OperatingSystem
    let year: UInt
    
    init(name: String, lastestSupportedOS: OperatingSystem, year: UInt) {
        self.name = name
        self.lastestSupportedOS = lastestSupportedOS
        self.year = year
    }
}
