//
//  AppDelegate.swift
//  Few
//
//  Created by Josh Abernathy on 7/22/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Cocoa

func every(interval: NSTimeInterval, fn: () -> ()) -> NSTimer {
	let timerTrampoline = TargetActionTrampoline()
	timerTrampoline.action = fn
	return NSTimer.scheduledTimerWithTimeInterval(interval, target: timerTrampoline, selector: timerTrampoline.selector, userInfo: nil, repeats: true)
}

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

func const<T, V>(val: T) -> (V -> T) {
	return { _ in val }
}

func id<T>(val: T) -> T {
	return val
}

func void<T, U>(fn: T -> U) -> (T -> ()) {
	return { t in
		fn(t)
		return ()
	}
}

func countLabel(state: State) -> Label<State> {
	return Label(text: "\(state.count)")
}

func render(state: State) -> Element<State> {
	if state.flipped {
		return Absolute(element: countLabel(state), frame: CGRect(x: 200, y: 0, width: 100, height: 23))
	} else {
		let resetButton = Button(title: state.title, fn: const(initialState))
		return Flow(countLabel(state), countLabel(state), resetButton, countLabel(state), countLabel(state))
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
