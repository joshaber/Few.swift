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
	let count = Label(text: "\(state.todos.count)")
	count.frame = CGRect(x: 0, y: 0, width: 100, height: 23)
	return count
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
