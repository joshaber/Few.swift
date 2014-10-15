//
//  AppDelegate.swift
//  Few
//
//  Created by Josh Abernathy on 7/22/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Cocoa
import Few

struct AppState {
	let todos = [String]()
}

func renderApp(component: Few.Component<AppState>, state: AppState) -> Element {
	// The [Element] cast works around a Swift runtime crash, lol?
	let todos = state.todos.map { Label(text: $0) } as [Element]
	for todo in todos {
		todo.key = "todo"
	}

	let list = List(todos)
	list.frame.size = CGSize(width: 200, height: 200)

	let field = Input(initialText: "", placeholder: "Todo") { str in }
	field.frame.size = CGSize(width: 150, height: 23)

	let addButton = Button(title: "Add") {
		let text = field.textField!.stringValue
		field.textField?.stringValue = ""

		var todos = state.todos
		todos.append(text)
		component.updateState(const(AppState(todos: todos)))
	}
	addButton.frame.size = CGSize(width: 50, height: 23)

	let fieldAndButton = Container(children: [field, addButton], layout: horizontalStack(10))
	fieldAndButton.frame.size = CGSize(width: 230, height: 23)

	return Container(children: [fieldAndButton, list], layout: verticalStack(10))
}

// This is to work around Swift's inability to have non-generic subclasses of a
// generic superclass.
typealias AppComponent = AppComponent_<Any>
class AppComponent_<Bullshit>: Few.Component<AppState> {
	init() {
		super.init(render: renderApp, initialState: AppState())
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
