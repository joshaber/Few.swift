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

func render(state: State) -> Element {
	// The [Element] cast is necessary because otherwise we crash trying to get
	// metadata?
	let todos = state.todos
	let items = todos.map { str in Label(text: str) } as [Element]
	for item in items {
		item.key = "item"
	}

	let list = List(items)
	list.frame = CGRect(x: 0, y: 0, width: 200, height: 200)

	let field = Input<State>(initialText: "") { (str, state) in
		return State(todos: state.todos, characterCount: state.characterCount + 1)
	}
	field.frame = CGRect(x: 0, y: 0, width: 100, height: 23)

	let addButton = Button<State>(title: "Add") { (state: State) in
		if let text = field.text {
			let realField = field.getContentView()! as NSTextField
			realField.stringValue = ""
			let newTodos = concat(todos, text)
			return State(todos: newTodos, characterCount: state.characterCount)
		} else {
			return state
		}
	}
	addButton.frame = CGRect(x: 0, y: 0, width: 40, height: 23)

	let countLabel = Label(text: "\(state.characterCount)")
	countLabel.frame = CGRect(x: 0, y: 0, width: 50, height: 23)

	let form = Container(children: [field, addButton, list], layout: formLayout)
	form.frame = CGRect(x: 0, y: 0, width: 200, height: 300)
	return Container(children: [form, countLabel], layout: horizontalStack(10))
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

struct State {
	let todos = [String]()
	let characterCount = 0
}

// This is to work around Swift's inability to have non-generic subclasses of a
// generic superclass.
typealias AppComponent = AppComponent_<Any>
class AppComponent_<Bullshit>: Few.Component<State> {
	init() {
		let initial = (1...100).map { "\($0)" }
		super.init(render: render, initialState: State(todos: initial, characterCount: 0))
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
