# DLSuggestionsTextField


## Why another framework for suggestions / autocomplete?

Even if there are some frameworks which provide this facility, each of them have various flaws or limitations. The purpose of this framework is to provide its client full control.

## Releases

**Version: 1.0.0**

Support for Swift 3.

**Version 2.0.0**

Support for Swift 4.
API has been simplified and now provides more customization.

## Installation

### Carthage

Add the the following dependecy in your `Cartfile`.

```
github "davidlivadaru/DLSuggestionsTextField" ~> 2.0
```

### CocoaPods

Add the the following dependecy in your `Podfile`.

```
pod 'DLSuggestionsTextField', '~> 2.0'
```

### Swift Package Manager

Add the the following dependecy in your `Package.swift`.

```
dependencies: [
    .package(url: "https://github.com/davidlivadaru/DLSuggestionsTextField.git", .upToNextMinor(from: "2.0.0"))
]
```

## Usage

Import the framework, configure the textField and set the `suggestionLabel` and `suggestionsContentView`.

```Swift
import DLSuggestionsTextField

...

  @IBOutlet weak var suggestionsTextField: TextField!
  private let suggestionsTableView = TableView()
  private let suggestionsLabel = UILabel()

  ...

  func viewDidload() {
    ...
    suggestionsTextField.suggestionLabel = suggestionsLabel
    suggestionsTextField.suggestionsContentView = suggestionsTableView
  }
```

The framework client has to:

* provide a suggestions content view - here sugestions should be placed;
* (optional) provide a suggestion text view - here proposed selection is placed;
* handle the filtering based on data from textField;
* manage the content and text views.

## Issues

If you did find a bug [create an issue](https://github.com/davidlivadaru/DLSuggestionsTextField/issues/new).

If you fixed a bug or an issue or added new functionality to the framework [create a pull request](https://github.com/davidlivadaru/DLSuggestionsTextField/compare).

## License

The project is released under MIT license. For further details read [LICENSE](LICENSE) file.