//
//  CGGeometry+Additions.swift
//  DLSuggestionsTextField
//
//  Created by David Livadaru on 08/07/16.
//  Copyright © 2016 Community. All rights reserved.
//

import CoreGraphics


public protocol RoundApplicable {
    mutating func roundInPlace()
}

public protocol CeilApplicable {
    mutating func ceilInPlace()
}

public protocol FloorApplicable {
    mutating func floorInPlace()
}

extension CGRect : RoundApplicable, FloorApplicable, CeilApplicable {
    mutating public func roundInPlace() {
        self = CGRect(x: round(self.origin.x), y: round(origin.y), width: round(width), height: round(height))
    }
    
    mutating public func floorInPlace() {
        self = CGRect(x: floor(self.origin.x), y: floor(origin.y), width: floor(width), height: floor(height))
    }
    
    mutating public func ceilInPlace() {
        self = CGRect(x: ceil(self.origin.x), y: ceil(origin.y), width: ceil(width), height: ceil(height))
    }
}

extension CGSize : RoundApplicable, FloorApplicable, CeilApplicable {
    mutating public func roundInPlace() {
        self = CGSize(width: round(width), height: round(height))
    }
    
    mutating public func floorInPlace() {
        self = CGSize(width: floor(width), height: floor(height))
    }
    
    mutating public func ceilInPlace() {
        self = CGSize(width: ceil(width), height: ceil(height))
    }
}

extension CGPoint : RoundApplicable, FloorApplicable, CeilApplicable {
    mutating public func roundInPlace() {
        self = CGPoint(x: round(x), y: round(y))
    }
    
    mutating public func floorInPlace() {
        self = CGPoint(x: floor(x), y: floor(y))
    }
    
    mutating public func ceilInPlace() {
        self = CGPoint(x: ceil(x), y: ceil(y))
    }
}

extension CGRect {
    mutating public func insetInPlace(point: CGPoint) {
        insetInPlace(dx: point.x, dy: point.y)
    }
    
    mutating public func insetInPlace(insets: UIEdgeInsets) {
        self = UIEdgeInsetsInsetRect(self, insets)
    }
}
