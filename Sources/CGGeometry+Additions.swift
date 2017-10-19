//
//  CGGeometry+Additions.swift
//  DLSuggestionsTextField
//
//  Created by David Livadaru on 08/07/16.
//  Copyright © 2016 Community. All rights reserved.
//

import CoreGraphics

public protocol CeilApplicable {
    mutating func ceil()
    func ceiling() -> Self
}

extension CeilApplicable {
    mutating public func ceil() {
        self = ceiling()
    }
}

public protocol FloorApplicable {
    mutating func floor()
    func floored() -> Self
}

extension FloorApplicable {
    mutating public func floor() {
        self = floored()
    }
}

public protocol RoundApplicable {
    mutating func round()
    func rounded() -> Self
}

extension RoundApplicable {
    mutating public func round() {
        self = rounded()
    }
}

extension CGRect: RoundApplicable, FloorApplicable, CeilApplicable {
    public func ceiling() -> CGRect {
        return CGRect(x: Darwin.ceil(self.origin.x), y: Darwin.ceil(origin.y),
                      width: Darwin.ceil(width), height: Darwin.ceil(height))
    }

    public func floored() -> CGRect {
        return CGRect(x: Darwin.floor(self.origin.x), y: Darwin.floor(origin.y),
                      width: Darwin.floor(width), height: Darwin.floor(height))
    }

    public func rounded() -> CGRect {
        return CGRect(x: Darwin.round(self.origin.x), y: Darwin.round(origin.y),
                      width: Darwin.round(width), height: Darwin.round(height))
    }
}

extension CGSize: RoundApplicable, FloorApplicable, CeilApplicable {
    public func ceiling() -> CGSize {
        return CGSize(width: Darwin.ceil(width), height: Darwin.ceil(height))
    }

    public func floored() -> CGSize {
        return CGSize(width: Darwin.floor(width), height: Darwin.floor(height))
    }

    public func rounded() -> CGSize {
        return CGSize(width: Darwin.round(width), height: Darwin.round(height))
    }
}

extension CGPoint: RoundApplicable, FloorApplicable, CeilApplicable {
    public func ceiling() -> CGPoint {
        return CGPoint(x: Darwin.ceil(x), y: Darwin.ceil(y))
    }

    public func floored() -> CGPoint {
        return CGPoint(x: Darwin.floor(x), y: Darwin.floor(y))
    }

    public func rounded() -> CGPoint {
        return CGPoint(x: Darwin.round(x), y: Darwin.round(y))
    }
}

extension CGRect {
    mutating public func insetBy(point: CGPoint) {
        insetBy(dx: point.x, dy: point.y)
    }

    public func insetedBy(point: CGPoint) -> CGRect {
        var rect = self
        rect.insetBy(point: point)
        return rect
    }

    mutating public func insetUsing(insets: UIEdgeInsets) {
        self = insetedUsing(insets: insets)
    }

    public func insetedUsing(insets: UIEdgeInsets) -> CGRect {
        return UIEdgeInsetsInsetRect(self, insets)
    }
}
