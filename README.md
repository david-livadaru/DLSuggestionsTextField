# DLSuggestionsTextField


## Why another framework for suggestions / autocomplete?

Even if there are some frameworks which provide this facility, each of them have various flaws or limitations. The purpose of this framework is to provide its client full control.

## Releases

**Version: 1.0.0**

Support for Swift 3 and Xcode 8.

## Installation

### Git submodule

It's as easy as: drag&drop project file into your project/workspace and embed the framework. Note that you have to set the module at the desired commit which is tagged a version.

```
git submodule add https://github.com/davidlivadaru/DLSuggestionsTextField.git
```

### Carthage

```
github "davidlivadaru/DLSuggestionsTextField" ~> 1.0
```

### CocoaPods

```
pod 'DLSuggestionsTextField', '~> 1.0'
```

### Usages

Import the framework, set the data source and delegate, configure the textField and prepare it for display.

```Swift
import DLSuggestionsTextField

...

  @IBOutlet weak var suggestionsTextField: SuggestionsTextField!

  ...

  func viewDidload() {
    ...
    suggestionsTextField.dataSource = self
    suggestionsTextField.configurationDelegate = self
    suggestionsTextField.prepareForDisplay()
```

The framework client is responsible to:

* provide a suggestions content view
* (optional) provide a suggestion text view
* handle the filtering based on data from textField
* manage the content and text views

A suggestions content view is a view where the list of suggestions is presented. May be an instance of UITableView or UICollectionView or any class that implements the ` SuggestionsContentViewType `.
A text view is a view is a view which display the proposed suggestion based on user's input (the same way Google Search works).

SuggestionsTextField was not created with generics because it would have been removed its use in Interface Builder files. The solution I chose is protocols; the drawback is that the framework client has to retain the view sent to the framework as data source or downcast where needed (which should be avoided).

### What's next?

- [ ] Update Demo project with more examples. (Coming soon.)
- [ ] Provide support for **Swift Package Manager**. (Coming soon).

### Issues

If you did find a bug [create an issue](https://github.com/davidlivadaru/DLSuggestionsTextField/issues/new).

If you fixed a bug or an issue or added new functionality to the framework [create a pull request](https://github.com/davidlivadaru/DLSuggestionsTextField/compare).

### License

The project is released under MIT license. For further details read [LICENSE](LICENSE) file.