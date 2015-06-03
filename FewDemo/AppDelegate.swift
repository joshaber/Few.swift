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

func renderApp(component: Component<ActiveComponent>, state: ActiveComponent) -> Element {
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
				.margin(Edges(top: 20))
		])

//	return Element()
//		.direction(.Column)
//		.justification(.Center)
//		.children([
//			Element().height(90).children([
//				View(backgroundColor: .grayColor()).width(32),
//				View(backgroundColor: .blackColor(), cornerRadius: 20).width(40).height(40).margin(Edges(left: -10)).selfAlignment(.Center),
//				Element().selfAlignment(.Center).direction(.Column).flex(1).children([
//					Label("Lorem Ipsum"),
//					Label("Dolor"),
//				]),
//				View(backgroundColor: .blackColor()).width(30).height(30).selfAlignment(.Center).margin(Edges(right: 10))
//			])
//		])
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
		let contentView = window.contentView as! NSView
		appComponent.addToView(contentView)
	}
}
