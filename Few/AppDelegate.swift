//
//  AppDelegate.swift
//  Few
//
//  Created by Josh Abernathy on 7/22/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Cocoa

struct State {
	let title: String
	let count: Int
	let flipped: Bool
}

extension State: Equatable {}

func ==(lhs: State, rhs: State) -> Bool {
	return lhs.title == rhs.title && lhs.count == rhs.count && lhs.flipped == rhs.flipped
}

let initialState = State(title: "Reset!", count: 1, flipped: false)

func countLabel(state: State) -> Label<State> {
	return Label(text: "\(state.count)")
}

func resetButton(state: State) -> Button<State> {
	return Button(title: state.title, fn: const(initialState))
}

func render(state: State) -> Element<State> {
	if state.flipped {
		return Absolute(element: countLabel(state), frame: CGRect(x: 200, y: 0, width: 100, height: 23))
	} else {
		return Flow(countLabel(state), resetButton(state), countLabel(state), resetButton(state), countLabel(state), resetButton(state), countLabel(state))
	}
}

class AppDelegate: NSObject, NSApplicationDelegate {
	@IBOutlet weak var window: NSWindow!

	private let component = Component(render: render, initialState: initialState)

	func applicationDidFinishLaunching(notification: NSNotification?) {
		let contentView = window.contentView as NSView
		component.addToView(contentView)

		every(1) {
			let state = self.component.state
			var newFlip = state.flipped
			if state.count % 10 == 0 {
				newFlip = !state.flipped
			}

			self.component.state = State(title: state.title, count: state.count + 1, flipped: newFlip)
		}
	}
}
