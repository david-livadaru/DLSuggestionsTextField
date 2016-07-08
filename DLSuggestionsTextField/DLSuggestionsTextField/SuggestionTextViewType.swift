//
//  SuggestionTextViewType.swift
//  DLSuggestionsTextField
//
//  Created by David Livadaru on 08/07/16.
//  Copyright © 2016 Community. All rights reserved.
//

import UIKit


@objc public protocol SuggestionTextViewType : UIViewType {
    var attributedText: NSAttributedString? { get }
}

extension UILabel : SuggestionTextViewType {}
