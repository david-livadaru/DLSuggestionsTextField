//
//  ContentViewTraits.swift
//  DLSuggestionsTextField
//
//  Created by David Livadaru on 08/07/16.
//  Copyright © 2016 Community. All rights reserved.
//

import Foundation
import CoreGraphics

open class ContentViewTraits: NSObject {
    open let frame: CGRect

    public init(frame: CGRect = CGRect.zero) {
        self.frame = frame
        super.init()
    }
}
