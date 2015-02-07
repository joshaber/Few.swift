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

func textChanged(component: Few.Component<AppState>)(text: String) {
	component.updateState { AppState(username: text, password: $0.password) }
}

func renderInput(component: Few.Component<AppState>, label: String, secure: Bool, fn: (AppState, String) -> AppState) -> Element {
	let action: String -> () = { str in
		component.updateState { fn($0, str) }
	}
	let base: Element = {
		if secure {
			return Password(text: nil, fn: action)
		} else {
			return Input(text: nil, fn: action)
		}
	}()
	return View()
		.direction(.Row)
		.children([
			Label(text: label).size(75, 19),
			base.size(100, 23),
		])
}

func renderLogin(component: Few.Component<AppState>, state: AppState) -> Element {
	let loginEnabled = (state.username.utf16Count > 0 && state.password.utf16Count > 0)
	return View()//backgroundColor: NSColor.blueColor())
		.direction(.Column)
		.children([
			renderInput(component, "Username", true) { AppState(username: $1, password: $0.username) },
			renderInput(component, "Password", true) { AppState(username: $0.username, password: $1) },
			Button(title: "Login", enabled: loginEnabled) {}
				.selfAlignment(.FlexEnd)
				.margin(Edges(bottom: 4)),
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

	func applicationDidFinishLaunching(notification: NSNotification?) {
		let contentView = window.contentView as NSView
		appComponent.addToView(contentView)
	}
}
