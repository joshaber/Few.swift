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
}

func renderApp(component: Component<ActiveComponent>, state: ActiveComponent) -> Element {
	let contentComponent: Element
	switch state {
	case .Demo:
		contentComponent = Demo()
	case .Converter:
		contentComponent = CurrencyConverter()
	}

	return Element()
		.justification(.Center)
		.childAlignment(.Center)
		.direction(.Column)
		.children([
			contentComponent,
			CustomButton(title: "Go team go!") {
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
		return .Demo
	}
}

class AppDelegate: NSObject, NSApplicationDelegate {
	@IBOutlet weak var window: NSWindow!

	private let appComponent = Component(initialState: .Demo, render: renderApp)

	func applicationDidFinishLaunching(notification: NSNotification) {
		let contentView = window.contentView as! NSView
		appComponent.addToView(contentView)
	}
}
