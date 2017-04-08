//
//  Storage.swift
//  DLSuggestionsTextFieldDemo
//
//  Created by David Livadaru on 13/08/16.
//  Copyright © 2016 Community. All rights reserved.
//

import Foundation

class Storage {
    let phones: [Phone]
    
    init() {
        let version3_1_3 = OperatingSystemVersion(majorVersion: 3, minorVersion: 1, patchVersion: 3)
        let iPhoneOS3 = OperatingSystem(name: "iPhone OS", version: version3_1_3)
        let iOS4_2_1 = OperatingSystem(version: OperatingSystemVersion(majorVersion: 4, minorVersion: 2, patchVersion: 1))
        let iOS6_1_6 = OperatingSystem(version: OperatingSystemVersion(majorVersion: 6, minorVersion: 1, patchVersion: 6))
        let iOS7_1_2 = OperatingSystem(version: OperatingSystemVersion(majorVersion: 7, minorVersion: 1, patchVersion: 2))
        let iOS9_3_4 = OperatingSystem(version: OperatingSystemVersion(majorVersion: 9, minorVersion: 3, patchVersion: 4))
        let iOS10Beta = OperatingSystem(name: "iOS 10 Beta",
                                        version: OperatingSystemVersion(majorVersion: 10, minorVersion: 0, patchVersion: 0))
        
        let iPhoneFirstGen = Phone(name: "iPhone (1st Gen)", lastestSupportedOS: iPhoneOS3, year: 2007)
        let iPhone3G = Phone(name: "iPhone 3G", lastestSupportedOS: iOS4_2_1, year: 2008)
        let iPhone3GS = Phone(name: "iPhone 3GS", lastestSupportedOS: iOS6_1_6, year: 2009)
        let iPhone4 = Phone(name: "iPhone 4", lastestSupportedOS: iOS7_1_2, year: 2010)
        let iPhone4S = Phone(name: "iPhone 4S", lastestSupportedOS: iOS9_3_4, year: 2011)
        let iPhone5 = Phone(name: "iPhone 5", lastestSupportedOS: iOS10Beta, year: 2012)
        let iPhone5S = Phone(name: "iPhone 5S", lastestSupportedOS: iOS10Beta, year: 2013)
        let iPhone5C = Phone(name: "iPhone 5C", lastestSupportedOS: iOS10Beta, year: 2013)
        let iPhone6 = Phone(name: "iPhone 6", lastestSupportedOS: iOS10Beta, year: 2014)
        let iPhone6Plus = Phone(name: "iPhone 6 Plus", lastestSupportedOS: iOS10Beta, year: 2014)
        let iPhone6S = Phone(name: "iPhone 6S", lastestSupportedOS: iOS10Beta, year: 2015)
        let iPhone6SPlus = Phone(name: "iPhone 6S Plus", lastestSupportedOS: iOS10Beta, year: 2015)
        let iPhoneSE = Phone(name: "iPhone SE", lastestSupportedOS: iOS10Beta, year: 2016)
        
        phones = [iPhoneFirstGen, iPhone3G, iPhone3GS, iPhone4, iPhone4S, iPhone5, iPhone5C, iPhone5S, iPhone6,
                  iPhone6Plus, iPhone6S, iPhone6SPlus, iPhoneSE]
    }
}
