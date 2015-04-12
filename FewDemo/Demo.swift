//
//  Demo.swift
//  Few
//
//  Created by Josh Abernathy on 3/10/15.
//  Copyright (c) 2015 Josh Abernathy. All rights reserved.
//

import Foundation
import Few
import AppKit

struct LoginState {
	let username: String
	let password: String
	init(username: String = "", password: String = "") {
		self.username = username
		self.password = password
	}
}

private func renderInput(component: Few.Component<LoginState>, label: String, secure: Bool, fn: (LoginState, String) -> LoginState) -> Element {
	let action: String -> () = { str in
		component.updateState { fn($0, str) }
	}

	var input: Element!
	if secure {
		input = Password(action: action)
	} else {
		input = Input(action: action).autofocus(true)
	}

	return View()
		.direction(.Row)
		.padding(Edges(bottom: 4))
		.children([
			Label(label).size(75, 19),
			input.size(100, 23),
		])
}

struct ScrollViewState {
	let selectedRow: Int?
	let items: [Int]
	init(items: [Int] = Array(1...100), selectedRow: Int? = nil) {
		self.items = items
		self.selectedRow = selectedRow
	}
}

private func keyDown(event: NSEvent, component: Few.Component<ScrollViewState>) -> Bool {
	let characters = event.charactersIgnoringModifiers!.utf16
	let firstCharacter = first(characters)
	if firstCharacter == UInt16(NSDeleteCharacter) {
		component.updateState { state in
			var items = state.items
			items.removeAtIndex <^> state.selectedRow
			return ScrollViewState(selectedRow: state.selectedRow, items: items)
		}
		return true
	} else {
		return false
	}
}

private func renderScrollView() -> Element {
	return Component(initialState: ScrollViewState()) { component, state in
		let items = state.items.map { row in renderRow(row) }
		let itemPlurality = (items.count == 1 ? "item" : "items")
		return View(
			keyDown: { _, event in
				return keyDown(event, component)
			})
			.direction(.Column)
			.children([
				Label("\(items.count) \(itemPlurality)"),
				TableView(items, selectionChanged: { row in
					component.updateState { ScrollViewState(selectedRow: row, items: $0.items) }
				})
				.flex(1)
			])
	}
}

private func renderRow(row: Int) -> Element {
	return View()
		.direction(.Column)
		.children([
			Label("I am a banana.", textColor: NSColor.yellowColor(), font: NSFont.systemFontOfSize(18)),
			Label("\(row)"),
			Image(NSImage(named: NSImageNameApplicationIcon)).size(42, 42),
		])
}

private func renderLogin() -> Element {
	return Component(initialState: LoginState()) { component, state in
		let loginEnabled = !state.username.isEmpty && !state.password.isEmpty
		return Element()
			.direction(.Column)
			.children([
				renderThingy(count(state.username.utf16)),
				renderInput(component, "Username", false) {
					LoginState(username: $1, password: $0.password)
				},
				renderInput(component, "Password", true) {
					LoginState(username: $0.username, password: $1)
				},
				Button(title: "Login", enabled: loginEnabled, action: {})
					.selfAlignment(.FlexEnd)
					.margin(Edges(bottom: 10, top: 10)),
			])
	}
}

private func renderThingy(count: Int) -> Element {
	let even = count % 2 == 0
	return (even ? Empty() : View(backgroundColor: NSColor.blueColor())).size(100, 50)
}

typealias Demo = Demo_<()>
class Demo_<LOL>: Few.Component<()> {
	init() {
		super.init(initialState: ())
	}

	override func render() -> Element {
		return View()
			.justification(.Center)
			.childAlignment(.Center)
			.direction(.Column)
			.children([
				renderLogin(),
				renderScrollView().size(100, 100),
			])
	}
}
