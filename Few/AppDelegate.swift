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
	let flip: Bool
}

extension State: Equatable {}

func ==(lhs: State, rhs: State) -> Bool {
	return lhs.title == rhs.title && lhs.count == rhs.count && lhs.flip == rhs.flip
}

let initialState = State(title: "Hi!", count: 1, flip: false)

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
	return Label(size: CGSize(width: 100, height: 23), text: "\(state.count)")
}

func render(state: State) -> Element<State> {
	if state.flip {
		return Absolute(element: countLabel(state), frame: CGRect(x: 200, y: 0, width: 100, height: 23))
	} else {
		let resetButton = Button(size: CGSize(width: 100, height: 23), title: state.title, fn: const(initialState))
		return Flow(countLabel(state), resetButton, countLabel(state), countLabel(state), countLabel(state))
	}
}

class AppDelegate: NSObject, NSApplicationDelegate {
	@IBOutlet weak var window: NSWindow!

	private let component = Component(render: render, initialState: initialState)

	func applicationDidFinishLaunching(notification: NSNotification?) {
		let contentView = window.contentView as NSView
		component.addToView(contentView)

		every(0.1) {
			let state = self.component.state
			var newFlip = state.flip
			if state.count % 20 == 0 {
				newFlip = !state.flip
			}

			self.component.state = State(title: state.title, count: state.count + 1, flip: newFlip)
		}
	}
}
