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
	let todos: [String] = []
	let like = false
}

func renderApp(component: Few.Component<AppState>, state: AppState) -> Element {
	let count = Label(text: "\(state.todos.count)")
	count.frame.size = CGSize(width: 100, height: 23)

	let button = Button(title: "Add") {
		component.updateState { state in
			AppState(todos: state.todos + ["a nu todo"], like: state.like)
		}
		return ()
	}
	button.frame.size = CGSize(width: 50, height: 23)

	let likedness = state.like ? "do" : "donut"
	let statusLabel = Label(text: "I \(likedness) like this.")
	statusLabel.frame.size = CGSize(width: 100, height: 23)

	let toggleButton = Button(title: "Toggle") {
		component.updateState { state in
			AppState(todos: state.todos, like: !state.like)
		}
		return ()
	}
	toggleButton.frame.size = CGSize(width: 75, height: 23)

	let layout = offset(CGPoint(x: 20, y: 0)) >-- verticalStack(12)
	return Container(children: [count, button, statusLabel, toggleButton], layout: layout)
}

private let initialState = AppState(todos: (1...100).map { "\($0)" }, like: false)

class AppDelegate: NSObject, NSApplicationDelegate {
	@IBOutlet weak var window: NSWindow!

	private let appComponent = Component(render: renderApp, initialState: initialState)
	
	func applicationDidFinishLaunching(notification: NSNotification?) {
		let contentView = window.contentView as NSView
		appComponent.addToView(contentView)
	}
}
