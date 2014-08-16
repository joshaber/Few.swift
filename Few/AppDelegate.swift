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

func renderForm(state: State) -> Element<State> {
	let incButton = Button(title: "Increment", fn: { mapCount($0, inc) })
				 |> sizeToFit
				 |> offset(0, 40)

	let decButton = Button(title: "Decrement", fn: { mapCount($0, dec) })
				 |> sizeToFit

	let count = Label<State>(text: "\(state.count)")
			 |> sizeToFit
			 |> offset(0, 20)

	return offset(incButton + count + decButton, 200, 200)
}

func renderBackground(state: State) -> Element<State> {
	var element: Element<State> = empty()
	if state.count < 0 {
		element = rect(NSColor.redColor().colorWithAlphaComponent(0.5))
	} else if state.count > 0 {
		element = rect(NSColor.greenColor().colorWithAlphaComponent(0.5))
	}
	
	return absolute(element, CGSize(width: 1000, height: 1000))
}

func renderLost() -> Element<State> {
	return Label(text: "Y O U  L O S E")
		|> sizeToFit
		|> absolute(CGPoint(x: 200, y: 225))
}

func renderWon() -> Element<State> {
	return Label(text: "Y O U  W I N")
		|> sizeToFit
		|> absolute(CGPoint(x: 200, y: 225))
}

func renderReset() -> Element<State> {
	return Button(title: "Reset", fn: const(State(count: 0)))
		|> sizeToFit
		|> absolute(CGPoint(x: 2, y: 300))
}

let scoreLimit = 5

func render(state: State) -> Element<State> {
	let bg = renderBackground(state)
	if state.count <= -scoreLimit {
		return bg + renderLost() + renderReset()
	} else if state.count >= scoreLimit {
		return bg + renderReset() + renderWon()
	} else {
		return bg + renderForm(state)
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
