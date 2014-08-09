//
//  AppDelegate.swift
//  Few
//
//  Created by Josh Abernathy on 7/22/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Cocoa

struct State {
	let count: Int
}

extension State: Equatable {}

func ==(lhs: State, rhs: State) -> Bool {
	return rhs.count == lhs.count
}

// TODO: We should really be using lenses here.
func mapCount(state: State, fn: Int -> Int) -> State {
	return State(count: fn(state.count))
}

func formElements(state: State) -> [Element<State>] {
	let incButton = Button(title: "Increment", fn: { mapCount($0, inc) })
	let decButton = Button(title: "Decrement", fn: { mapCount($0, dec) })
	let count = Label<State>(text: "\(state.count)")
	return [incButton, count, decButton]
}

func renderForm(state: State) -> Element<State> {
	return Flow(.Down, formElements(state))
}

func render(state: State) -> Element<State> {
	let form = renderForm(state)
	if state.count >= 0 {
		return form
	} else {
		let size = CGSize(width: 1000, height: 1000)
		let danger: Element<State> = rect(size, color: NSColor.redColor())
		return form + Absolute(element: danger, frame: CGRect(origin: CGPointZero, size: size))
	}
}

class AppDelegate: NSObject, NSApplicationDelegate {
	@IBOutlet weak var window: NSWindow!

	private let component = Component(render: render, initialState: State(count: 0))

	func applicationDidFinishLaunching(notification: NSNotification?) {
		let contentView = window.contentView as NSView
		component.addToView(contentView)
	}
}
