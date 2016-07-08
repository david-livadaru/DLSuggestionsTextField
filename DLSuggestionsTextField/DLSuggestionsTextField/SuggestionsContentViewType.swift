//
//  SuggestionsContentViewType.swift
//  DLSuggestionsTextField
//
//  Created by David Livadaru on 08/07/16.
//  Copyright © 2016 Community. All rights reserved.
//

import UIKit


@objc public protocol SuggestionsContentViewType : UIViewType {
    var contentSize: CGSize { get }
    
    func reloadData()
    func layoutIfNeeded()
}

extension UITableView : SuggestionsContentViewType {}

extension UICollectionView : SuggestionsContentViewType {}
