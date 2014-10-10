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

func render(todos: [String]) -> Container {
	// The [Element] cast is necessary because otherwise we crash trying to get
	// metadata?
	let items = todos.map { str in Label(text: str) } as [Element]
	for item in items {
		item.key = "item"
	}
	let list = List(items) //|> size(CGSize(width: 200, height: 200))
	list.frame = CGRect(x: 0, y: 0, width: 200, height: 200)

	let field = Input<[String]>(initialText: "") { (str, s) in s } //|> size(CGSize(width: 100, height: 23))
	field.frame = CGRect(x: 0, y: 0, width: 100, height: 23)

	let addButton = Button<[String]>(title: "Add") { (todos: [String]) in
		if let text = field.text {
			let realField = field.getContentView()! as NSTextField
			realField.stringValue = ""
			return concat(todos, text)
		} else {
			return todos
		}
	} //|> size(CGSize(width: 40, height: 23))
	addButton.frame = CGRect(x: 0, y: 0, width: 40, height: 23)

	return Container(children: [field, addButton, list], layout: containerLayout)
}

func containerLayout(container: Container, elements: [Element]) {
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

// This is to work around Swift's inability to have non-generic subclasses of a
// generic superclass.
typealias AppComponent = AppComponent_<Any>
class AppComponent_<Bullshit>: Few.Component<[String]> {
	init() {
		let initial = (1...1000).map { "\($0)" }
		super.init(render: render, initialState: initial)
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
