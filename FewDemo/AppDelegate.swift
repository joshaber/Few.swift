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

struct ScrollViewState {
	let selectedRow: Int? = nil
	let items: [Int] = Array(1...10)
}

func renderScrollView() -> Element {
	return Few.Component(initialState: ScrollViewState()) { component, state in
		let items = (0...10).map { row in renderRow(row, state.selectedRow, component) }
		return ScrollView(items)
	}
}

func renderRow(row: Int, selectedRow: Int?, component: Few.Component<ScrollViewState>) -> Element {
	let selected = selectedRow == row
	let backgroundColor = (selected ? NSColor.redColor() : NSColor.greenColor())
	let labelColor = (selected ? NSColor.whiteColor() : NSColor.blackColor())
	return View(
		backgroundColor: backgroundColor,
		mouseDown: { _ in
			component.updateState { ScrollViewState(selectedRow: row, items: $0.items) }
		})
		.children([
			Label(text: "Item \(row + 1)", textColor: labelColor)
		])
}

func renderLogin() -> Element {
	return Component(initialState: AppState()) { component, state in
		let loginEnabled = (state.username.utf16Count > 0 && state.password.utf16Count > 0)
		return Element()
			.direction(.Column)
			.children([
				renderThingy(state.username.utf16Count),
				renderInput(component, "Username", false) {
					AppState(username: $1, password: $0.password)
				},
				renderInput(component, "Password", true) {
					AppState(username: $0.username, password: $1)
				},
				Button(title: "Login", enabled: loginEnabled) {}
					.selfAlignment(.FlexEnd)
					.margin(Edges(bottom: 4)),
			])
	}
}

func renderThingy(count: Int) -> Element {
	let even = count % 2 == 0
	return (even ? Empty() : View(backgroundColor: NSColor.blueColor())).size(100, 50)
}

func renderApp(component: Few.Component<()>, state: ()) -> Element {
	return View()
		.justification(.Center)
		.childAlignment(.Center)
		.direction(.Column)
		.children([
			renderLogin(),
			renderScrollView().size(100, 100),
		])
}

class AppDelegate: NSObject, NSApplicationDelegate {
	@IBOutlet weak var window: NSWindow!

	private let appComponent = Few.Component(initialState: (), render: renderApp)

	func applicationDidFinishLaunching(notification: NSNotification) {
		let contentView = window.contentView as! NSView
		appComponent.addToView(contentView)
	}
}
