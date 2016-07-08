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
    
    func addSubviewType(viewType: UIViewType)
    func removeFromSuperViewType()
    
    func systemLayoutSizeFittingSize(targetSize: CGSize) -> CGSize
}

extension UIView : UIViewType {
    public func addSubviewType(viewType: UIViewType) {
        guard let view = viewType as? UIView else { return }
        addSubview(view)
    }
    
    public func removeFromSuperViewType() {
        removeFromSuperview()
    }
}