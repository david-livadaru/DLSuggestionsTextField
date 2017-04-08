//
//  UIViewType.swift
//  DLSuggestionsTextField
//
//  Created by David Livadaru on 08/07/16.
//  Copyright © 2016 Community. All rights reserved.
//

import UIKit

@objc public protocol UIViewType : NSObjectProtocol {
    var frame: CGRect { get set }
    
    func addSubview(_ view: UIView)
    func removeFromSuperview()
    
    func systemLayoutSizeFittingSize(_ targetSize: CGSize) -> CGSize
}

extension UIView : UIViewType {}
