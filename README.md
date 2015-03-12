# Few.swift

[React](http://facebook.github.io/react/)-inspired library in Swift for writing
UIs which are functions of their state.<sup><a href="#lol">1</a></sup>

[SwiftBox](https://github.com/joshaber/SwiftBox) is used for layout.

## Why

[UIs are big, messy, mutable, stateful bags of sadness.](http://joshaber.github.io/2015/01/30/why-react-native-matters/)

Few.swift lets us express UIs as stateless, composable, immutable-ish values of
their state. When their state changes, Few.swift calls a designated render
function and intelligently applies any changes.

The state is the necessary complexity of the view. The view is a mapping from
state to its representation.

## Example

Here's a simple example which counts the number of times a button is clicked:

```swift
// This function is called every time `component.updateState` is called.
func renderApp(component: Component<Int>, count: Int) -> Element {
	return View()
		// The view itself should be centered.
		.justification(.Center)
		// The children should be centered in the view.
		.childAlignment(.Center)
		// Layout children in a column.
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

Or a slightly more involved example, a temperature converter:

```swift
struct ConverterState {
	static let defaultFahrenheit: CGFloat = 32

	let fahrenheit: CGFloat = defaultFahrenheit
	let celcius: CGFloat = f2c(defaultFahrenheit)
}

private func c2f(c: CGFloat) -> CGFloat {
	return (c * 9/5) + 32
}

private func f2c(f: CGFloat) -> CGFloat {
	return (f - 32) * 5/9
}

private func renderLabeledInput(label: String, value: String, autofocus: Bool, fn: String -> ()) -> Element {
	return View()
		// Layout children in a row.
		.direction(.Row)
		.padding(Edges(bottom: 4))
		.children([
			Label(label).width(75),
			Input(
				text: value,
				placeholder: label,
				enabled: true,
				action: fn)
				// Autofocus means that the Input will become the first responder when
				// it is first added to the window.
				.autofocus(autofocus)
				.width(100),
		])
}

private func render(component: Few.Component<ConverterState>, state: ConverterState) -> Element {
	let numberFormatter = NSNumberFormatter()
	let parseNumber: String -> CGFloat? = { str in
		return (numberFormatter.numberFromString(str)?.doubleValue).map { CGFloat($0) }
	}
	return View()
		// Center the view.
		.justification(.Center)
		// Center the children.
		.childAlignment(.Center)
		.direction(.Column)
		.children([
			// Each time the text fields change, we re-render. But note that Few.swift
			// is smart enough not to interrupt the user's editing or selection.
			renderLabeledInput("Fahrenheit", "\(state.fahrenheit)", true) {
				if let f = parseNumber($0) {
					component.updateState { _ in ConverterState(fahrenheit: f, celcius: f2c(f)) }
				}
			},
			renderLabeledInput("Celcius", "\(state.celcius)", false) {
				if let c = parseNumber($0) {
					component.updateState { _ in ConverterState(fahrenheit: c2f(c), celcius: c) }
				}
			},
		])
}
```

See [FewDemo](FewDemo) for some more involved examples.

## How does this compare to React-Native/Components?

This is pure conjecture since neither are open source yet, but a few
differences I know of:

1. Few.swift is written in... Swift. Type safety is cool.
2. Single-threaded. React-Native and Components both do layout on a non-main
thread. Few.swift keeps everything on the main thread currently.
3. Both React-Native and Components are battle-tested. They've been used in
shipping apps. Few.swift has not.
4. React-Native has an awesome live reload feature.

## Quirks

Swift's pretty buggy with concrete subclasses of generic superclasses: https://gist.github.com/joshaber/0978209efef7774393e0.
This hurts.

## Should I use this?

Probably :doughnut:. See above about how it's not battle-tested yet. It's also
currently mostly OS X-only. iOS support is really basic. Pull requests welcome :sparkling_heart:.

--

<a name="lol"><sup>1.</sup></a> React, but for Cocoa. A reactive Cocoa, one might say.
