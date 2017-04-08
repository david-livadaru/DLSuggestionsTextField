//
//  KeyboardAnimationTraits.swift
//  DLSuggestionsTextField
//
//  Created by David Livadaru on 08/07/16.
//  Copyright © 2016 Community. All rights reserved.
//

import Foundation
import CoreGraphics

open class KeyboardAnimationTraits : NSObject {
    open let frame: CGRect
    open let duration: TimeInterval
    open let curve: UInt
    
    open var isKeyboardHidden: Bool {
        let screenBounds = UIScreen.main.bounds
        return frame.minY == screenBounds.maxY
    }
    
    public init(frame: CGRect = CGRect.zero, duration: TimeInterval = 0, curve: UInt = 0) {
        self.frame = frame
        self.duration = duration
        self.curve = curve
        
        super.init()
    }
}
