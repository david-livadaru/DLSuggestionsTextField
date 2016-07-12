//
//  ViewController.swift
//  DLSuggestionsTextFieldDemo
//
//  Created by David Livadaru on 08/07/16.
//  Copyright © 2016 Community. All rights reserved.
//

import UIKit
import DLSuggestionsTextField

class ViewController: UIViewController {
    @IBOutlet weak var suggestionsTextField: SuggestionsTextField!
    
    var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let textFieldFrame = suggestionsTextField.frame
        tableView = UITableView(frame: CGRect(x: textFieldFrame.minX, y: textFieldFrame.maxY, width: textFieldFrame.width, height: 0))
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: String(UITableViewCell))
        
        suggestionsTextField.dataSource = self
        suggestionsTextField.configurationDelegate = self
        suggestionsTextField.minEditingTextWidth = 8
        suggestionsTextField.prepareForDisplay()
    }
    
    @IBAction func controllerViewTapped(sender: UITapGestureRecognizer) {
        if sender.state == .Recognized {
            view.endEditing(true)
        }
    }
}

extension ViewController : SuggestionsTextFieldDataSource {
    func suggestionsTextFieldSuggestionsContentView(textField: SuggestionsTextField) -> SuggestionsContentViewType {
        return tableView
    }
    
    func suggestionsTextFieldSuggestionTextView(textField: SuggestionsTextField) -> SuggestionTextViewType {
        let label = UILabel()
        label.text = "Label"
        label.backgroundColor = UIColor.redColor()
        return label
    }
}

extension ViewController : SuggestionsTextFieldConfigurationDelegate {
    
    func suggestionsTextField(textField: SuggestionsTextField, proposedContentViewTraits contentViewTraits: SuggestionsContentViewTraits, keybordWillShowWith keyboardAnimationTraits: KeyboardAnimationTraits) {
        var hiddenContentViewFrame = contentViewTraits.frame
        hiddenContentViewFrame.size.height = 0
        
        tableView?.frame = hiddenContentViewFrame
        UIView.animateWithDuration(keyboardAnimationTraits.duration, delay: 0,
                                   options: UIViewAnimationOptions(rawValue: keyboardAnimationTraits.curve),
                                   animations: {
                                    self.tableView?.frame = contentViewTraits.frame
        }, completion: nil)
    }
    
    func suggestionsTextField(textField: SuggestionsTextField, keybordWillHideWith keyboardAnimationTraits: KeyboardAnimationTraits) {
        var hiddenContentViewFrame = tableView.frame
        hiddenContentViewFrame.size.height = 0
        
        UIView.animateWithDuration(keyboardAnimationTraits.duration, delay: 0,
                                   options: UIViewAnimationOptions(rawValue: keyboardAnimationTraits.curve),
                                   animations: {
                                    textField.suggestionsContentView?.frame = hiddenContentViewFrame
        }) { (finished) in
            if keyboardAnimationTraits.isKeyboardHidden {
                textField.hideSuggestionsContentView()
            }
        }
    }
    
    func suggestionsTextField(textField: SuggestionsTextField,
                              proposedContentViewTraits contentViewTraits: SuggestionsContentViewTraits,
                              keyboardAnimationTraits: KeyboardAnimationTraits) {
        var hiddenContentViewFrame = contentViewTraits.frame
        hiddenContentViewFrame.size.height = 0
        let initialTableViewFrame = keyboardAnimationTraits.isKeyboardHidden ? contentViewTraits.frame : hiddenContentViewFrame
        let finalTableViewFrame = keyboardAnimationTraits.isKeyboardHidden ? hiddenContentViewFrame : contentViewTraits.frame
        
        tableView?.frame = initialTableViewFrame
        UIView.animateWithDuration(keyboardAnimationTraits.duration, delay: 0,
                                   options: UIViewAnimationOptions(rawValue: keyboardAnimationTraits.curve),
                                   animations: {
                                    self.tableView?.frame = finalTableViewFrame
        }) { (finished) in
            if keyboardAnimationTraits.isKeyboardHidden {
                textField.hideSuggestionsContentView()
            }
        }
    }
    
    func suggestionsTextFieldDidChangeText(textField: SuggestionsTextField, completion: () -> Void) {
        print("Did change text: \(textField.text)")
    }
}

extension ViewController : UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(String(UITableViewCell), forIndexPath: indexPath)
        cell.backgroundColor = indexPath.row % 2 == 0 ? UIColor.blueColor() : UIColor.grayColor()
        return cell
    }
}

