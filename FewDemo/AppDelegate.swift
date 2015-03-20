//
//  AppDelegate.swift
//  Few
//
//  Created by Josh Abernathy on 7/22/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Cocoa
import Few

enum ActiveComponent {
	case Demo
	case Converter
	case Counter
}

let Counter: () -> Few.Component<Int> = {
	return Component(initialState: 0) { component, count in
		return View(
			backgroundColor: NSColor.blueColor())
			// The view itself should be centered.
			.justification(.Center)
			// The children should be centered in the view.
			.childAlignment(.Center)
			// Layout children in a column.
			.direction(.Column)
			.children([
				Label("You've clicked \(count) times!"),
				Button(title: "Click me!", action: {
						component.updateState { $0 + 1 }
					})
					.margin(Edges(uniform: 10))
					.width(100),
				])
    }
}

func renderApp(component: Few.Component<ActiveComponent>, state: ActiveComponent) -> Element {
	var contentComponent: Element!
	switch state {
	case .Demo:
		contentComponent = Demo()
	case .Converter:
		contentComponent = TemperatureConverter()
	case .Counter:
		contentComponent = Counter()
	}

	return Element()
		.justification(.Center)
		.childAlignment(.Center)
		.direction(.Column)
		.children([
			contentComponent,
			CustomButton(title: "Show me more!") {
					component.updateState(toggleDisplay)
				}
				.margin(Edges(bottom: 20))
		])
}

func toggleDisplay(display: ActiveComponent) -> ActiveComponent {
	switch display {
	case .Demo:
		return .Converter
	case .Converter:
		return .Counter
	case .Counter:
		return .Demo
	}
}

class AppDelegate: NSObject, NSApplicationDelegate {
	@IBOutlet weak var window: NSWindow!

	private let appComponent = Component(initialState: .Converter, render: renderApp)

	func applicationDidFinishLaunching(notification: NSNotification) {
		let contentView = window.contentView as NSView
		appComponent.addToView(contentView)
	}
}
