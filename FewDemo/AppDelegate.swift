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
	let todos = state.todos.map { Label(text: $0) }
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

	let removeButton = Button(title: "Remove") {
		var todos = state.todos
		todos.removeAtIndex(0)
		component.updateState(const(AppState(todos: todos)))
	}
	removeButton.frame.size = CGSize(width: 70, height: 23)

	let controls = Container(children: [field, addButton, removeButton], layout: horizontalStack(10))
	controls.frame.size = CGSize(width: 310, height: 23)

	return Container(children: [controls, list], layout: verticalStack(10))
}

private let initialState = AppState(todos: (1...100).map { "\($0)" })

class AppDelegate: NSObject, NSApplicationDelegate {
	@IBOutlet weak var window: NSWindow!

	private let appComponent = Component(render: renderApp, initialState: initialState)
	
	func applicationDidFinishLaunching(notification: NSNotification?) {
		let contentView = window.contentView as NSView
		appComponent.addToView(contentView)
	}
}
