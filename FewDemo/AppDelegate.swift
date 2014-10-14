//
//  AppDelegate.swift
//  Few
//
//  Created by Josh Abernathy on 7/22/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Cocoa
import Few

func concat<T>(array: [T], value: T) -> [T] {
	var copied = array
	copied.append(value)
	return copied
}

func noLayout(container: Container, elements: [Element]) {

}

func formLayout(container: Container, elements: [Element]) {
	alignLefts(20)(container: container, elements: elements)
	verticalStack(4)(container: container, elements: elements)
}

func alignLefts(origin: CGFloat)(container: Container, elements: [Element]) {
	for el in elements {
		el.frame.origin.x = origin
	}
}

func verticalStack(padding: CGFloat)(container: Container, elements: [Element]) {
	var y: CGFloat = container.frame.size.height - padding;
	for el in elements {
		y -= el.frame.size.height + padding
		el.frame.origin.y = y
	}
}

func horizontalStack(padding: CGFloat)(container: Container, elements: [Element]) {
	var x = padding
	for el in elements {
		el.frame.origin.x = x
		x += el.frame.size.width + padding
	}
}

func renderApp(component: Few.Component<Int>, state: Int) -> Element {
	let input = Input(initialText: "") { str in
		component.updateState(const(str.utf16Count))
		return ()
	}
	input.frame.size = CGSize(width: 100, height: 23)

	let label = Label(text: "\(state)")
	label.frame.size = CGSize(width: 100, height: 23)

	return Container(children: [input, label], layout: horizontalStack(10))
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
