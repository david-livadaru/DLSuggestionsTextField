//
//  ContentView.swift
//  DLSuggestionsTextField
//
//  Created by David Livadaru on 08/07/16.
//  Copyright © 2016 Community. All rights reserved.
//

import UIKit

@objc public protocol ContentView: class {
    func reloadData()
}

extension UITableView: ContentView {}

extension UICollectionView: ContentView {}
