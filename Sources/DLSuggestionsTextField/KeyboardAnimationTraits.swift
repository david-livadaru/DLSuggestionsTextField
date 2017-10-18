//
//  KeyboardAnimationTraits.swift
//  DLSuggestionsTextField
//
//  Created by David Livadaru on 08/07/16.
//  Copyright © 2016 Community. All rights reserved.
//

import Foundation
import UIKit

open class KeyboardAnimationTraits: NSObject {
    open let frame: CGRect
    open let duration: TimeInterval
    open let curve: UIViewAnimationOptions

    open var isKeyboardHidden: Bool {
        let screenBounds = UIScreen.main.bounds
        return frame.minY == screenBounds.maxY
    }

    public init(frame: CGRect = CGRect.zero, duration: TimeInterval = 0,
                curve: UIViewAnimationOptions = []) {
        self.frame = frame
        self.duration = duration
        self.curve = curve

        super.init()
    }

    public init?(notification: Notification) {
        let userInfo = notification.userInfo
        guard let frameValue = userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue else { return nil }
        guard let rawAnimationDuration = userInfo?[UIKeyboardAnimationDurationUserInfoKey] else { return nil }
        guard let animationDuration = (rawAnimationDuration as AnyObject).doubleValue else { return nil }
        guard let rawAnimationCurve = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] else { return nil }
        guard let animationCurve = (rawAnimationCurve as AnyObject).uintValue else { return nil }

        frame = frameValue.cgRectValue
        duration = animationDuration
        curve = UIViewAnimationOptions(rawValue: animationCurve)
    }
}
