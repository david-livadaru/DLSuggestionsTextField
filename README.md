# DLSuggestionsTextField

---
### Why another framework for suggestions / autocomplete?

Even if there are some frameworks which provide this facility, each of them have various flaws or limitations. The purpose of this framework is to provide its client full control.

### Installation

Apple provides project in project setup and that's the way to use to framework. It's as easy as: drag&drop project file into your project/workspace and embed the framework. Xcode will do the rest. Also this setup removes the 'fat binary' issues.
There won't ever be support for CocoaPods or Carthage. Sometime support for **Swift Package Manager** will be added.


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

### What's next?

- [ ] Update Demo project with a few meaningful example.
- [ ] Provide support for **Swift Package Manager**.

### Issues

If you did find a bug [create an issue](https://github.com/davidlivadaru/DLSuggestionsTextField/issues/new).

If you fixed a bug or an issue or added new functionality to the framework [create a pull request](https://github.com/davidlivadaru/DLSuggestionsTextField/compare).

### License

The project is released under MIT license. For further details read [LICENSE](LICENSE) file.