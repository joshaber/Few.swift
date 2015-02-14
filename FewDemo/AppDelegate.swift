//
//  AppDelegate.swift
//  Few
//
//  Created by Josh Abernathy on 7/22/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Cocoa
import Few
import SwiftBox

struct AppState {
	let username: String = ""
	let password: String = ""
}

func renderInput(component: Few.Component<AppState>, label: String, secure: Bool, fn: (AppState, String) -> AppState) -> Element {
	let action: String -> () = { str in
		component.updateState { fn($0, str) }
	}

	let input: Element
	if secure {
		input = Password(text: nil, fn: action)
	} else {
		input = Input(text: nil, fn: action)
	}

	return View()
		.direction(.Row)
		.padding(Edges(bottom: 4))
		.children([
			Label(text: label).size(75, 19),
			input.size(100, 23),
		])
}

func renderLogin(component: Few.Component<AppState>, state: AppState) -> Element {
	let loginEnabled = (state.username.utf16Count > 0 && state.password.utf16Count > 0)
	let items = (1...100).map { Label(text: "Item \($0)") }
	return View()//backgroundColor: NSColor.blueColor())
		.direction(.Column)
		.children([
			renderInput(component, "Username", true) { AppState(username: $1, password: $0.password) },
			renderInput(component, "Password", true) { AppState(username: $0.username, password: $1) },
			Button(title: "Login", enabled: loginEnabled) {}
				.selfAlignment(.FlexEnd)
				.margin(Edges(bottom: 4)),
			ScrollView(items).size(100, 100),
		])
}

func render(component: Few.Component<AppState>, state: AppState) -> Element {
	return View()//backgroundColor: NSColor.greenColor())
		.childAlignment(.Center)
		.justification(.Center)
		.children([
			renderLogin(component, state)
		])
}

class AppDelegate: NSObject, NSApplicationDelegate {
	@IBOutlet weak var window: NSWindow!

	private let appComponent = Few.Component(render: render, initialState: AppState())

	func applicationDidFinishLaunching(notification: NSNotification) {
		let contentView = window.contentView as!NSView
		appComponent.addToView(contentView)
	}
}
