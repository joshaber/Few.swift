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
	let selectedRow: Int? = nil
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

func renderRow(row: Int, selectedRow: Int?, component: Few.Component<AppState>) -> Element {
	let selected: Bool
	if let selectedRow = selectedRow {
		selected = selectedRow == row
	} else {
		selected = false
	}
	let color = (selected ? NSColor.redColor() : NSColor.greenColor())
	return View(
		backgroundColor: color,
		mouseDown: { _ in
			component.updateState { AppState(username: $0.username, password: $0.password, selectedRow: row) }
		})
		.children([
			Label(text: "Item \(row + 1)")
		])
}

func renderLogin(component: Few.Component<AppState>, state: AppState) -> Element {
	let loginEnabled = (state.username.utf16Count > 0 && state.password.utf16Count > 0)
	let items = (0...10).map { row in renderRow(row, state.selectedRow, component) }
	return View()
		.direction(.Column)
		.children([
			renderThingy(state.username.utf16Count),
			renderInput(component, "Username", false) { AppState(username: $1, password: $0.password, selectedRow: $0.selectedRow) },
			renderInput(component, "Password", true) { AppState(username: $0.username, password: $1, selectedRow: $0.selectedRow) },
			Button(title: "Login", enabled: loginEnabled) {}
				.selfAlignment(.FlexEnd)
				.margin(Edges(bottom: 4)),
			ScrollView(items).size(100, 100),
		])
}

func renderThingy(count: Int) -> Element {
	let color = (count % 2 == 0 ? NSColor.blueColor() : NSColor.yellowColor())
	return View(backgroundColor: color).size(100, 50)
}

func render(component: Few.Component<AppState>, state: AppState) -> Element {
	return View()
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
		let contentView = window.contentView as! NSView
		appComponent.addToView(contentView)
	}
}
