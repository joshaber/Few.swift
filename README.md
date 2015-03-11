# Few.swift

[React](http://facebook.github.io/react/)-inspired library in Swift for writing
UIs which are functions of their state.<sup><a href="#lol">1</a></sup>

## Why

[UIs are big, messy, mutable, stateful bags of sadness.](http://joshaber.github.io/2015/01/30/why-react-native-matters/)

Few.swift lets us express UIs as stateless, composable, immutable-ish values of
their state. When their state changes, Few.swift calls a designated render
function and intelligently applies any changes.

The state is the necessary complexity of the view. The view is a mapping from
state to its representation.

## Example

```swift
func renderApp(component: Component<Int>, count: Int) -> Element {
	return View()
		.justification(.Center)
		.childAlignment(.Center)
		.direction(.Column)
		.children([
			Label("You've clicked \(count) times!"),
			Button(title: "Click me!") {
					component.updateState { $0 + 1 }
				}
				.margin(Edges(uniform: 10))
				.width(100),
		])
}

class AppDelegate: NSObject, NSApplicationDelegate {
	@IBOutlet weak var window: NSWindow!

	private let appComponent = Component(initialState: 0, render: renderApp)

	func applicationDidFinishLaunching(notification: NSNotification) {
		let contentView = window.contentView as! NSView
		appComponent.addToView(contentView)
	}
}
```

[SwiftBox](https://github.com/joshaber/SwiftBox) is used for layout.

See [FewDemo](FewDemo) for some more involved examples.

## How does this compare to React-Native/Components?

This is pure conjecture since neither are open source yet, but a few
differences I know of:

1. Few.swift is written in... Swift. Type safety is cool.
2. Single-threaded. React-Native and Components both purport to do layout on a
non-main thread. Few.swift keeps everything on the main thread currently.
3. Both React-Native and Components are battle-tested. They've been used in
shipped apps. Few.swift has not.

## Quirks

Swift's pretty buggy with concrete subclasses of generic superclasses: https://gist.github.com/joshaber/0978209efef7774393e0.
This hurts.

--

<a name="lol"><sup>1.</sup></a> React, but for Cocoa. A reactive Cocoa, one might say.
