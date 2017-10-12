//
//  SuggestionTextViewType.swift
//  DLSuggestionsTextField
//
//  Created by David Livadaru on 08/07/16.
//  Copyright © 2016 Community. All rights reserved.
//

import UIKit


@objc public protocol SuggestionTextViewType: class {
    var attributedText: NSAttributedString? { get set }
}

extension UILabel : SuggestionTextViewType {}
