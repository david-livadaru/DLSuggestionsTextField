//
//  KeyboardAnimationTraits.swift
//  DLSuggestionsTextField
//
//  Created by David Livadaru on 08/07/16.
//  Copyright © 2016 Community. All rights reserved.
//

import Foundation
import CoreGraphics


public class KeyboardAnimationTraits : NSObject {
    public let frame: CGRect
    public let duration: NSTimeInterval
    public let curve: UInt
    
    public var isKeyboardHidden: Bool {
        let screenBounds = UIScreen.mainScreen().bounds
        return frame.minY == screenBounds.maxY
    }
    
    public init(frame: CGRect = CGRect.zero, duration: NSTimeInterval = 0, curve: UInt = 0) {
        self.frame = frame
        self.duration = duration
        self.curve = curve
        
        super.init()
    }
}
