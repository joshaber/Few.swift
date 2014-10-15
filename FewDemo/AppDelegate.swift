//
//  AppDelegate.swift
//  Few
//
//  Created by Josh Abernathy on 7/22/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Cocoa
import Few

func renderForm(buttonLabel: String, component: Few.Component<Int>, state: Int) -> Element {
	let input = Input(initialText: "", placeholder: "Text") { str in
		component.updateState(const(str.utf16Count))
		return ()
	}
	input.frame.size = CGSize(width: 100, height: 23)

	let label = Label(text: "\(state)")
	label.frame.size = CGSize(width: 100, height: 23)

	let button = Button(title: buttonLabel) {
		let rawInput = input.getContentView() as NSTextField!
		rawInput.stringValue = ""
		component.updateState(const(0))
	}
	button.frame.size = CGSize(width: 75, height: 23)

	let container = Container(children: [input, label, button], layout: horizontalStack(10))
	container.frame.size = CGSizeMake(305, 23)
	return container
}

func renderApp(component: Few.Component<Int>, state: Int) -> Element {
	return Container(children: [renderForm("Click me!", component, state), renderForm("Beat it", component, state)], layout: verticalStack(10) >-- offset(CGPoint(x: 20, y: -100)))
}

// This is to work around Swift's inability to have non-generic subclasses of a
// generic superclass.
typealias AppComponent = AppComponent_<Any>
class AppComponent_<Bullshit>: Few.Component<Int> {
	init() {
		super.init(render: renderApp, initialState: 0)
	}
}

class AppDelegate: NSObject, NSApplicationDelegate {
	@IBOutlet weak var window: NSWindow!

	private let appComponent = AppComponent()
	
	func applicationDidFinishLaunching(notification: NSNotification?) {
		let contentView = window.contentView as NSView
		appComponent.addToView(contentView)
	}
}
