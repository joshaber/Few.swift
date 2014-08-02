//
//  AppDelegate.swift
//  Few
//
//  Created by Josh Abernathy on 7/22/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Cocoa

func every(interval: NSTimeInterval, fn: () -> ()) -> NSTimer {
	let timerTrampoline = TargetActionTrampoline(action: fn)
	return NSTimer.scheduledTimerWithTimeInterval(interval, target: timerTrampoline, selector: timerTrampoline.selector, userInfo: nil, repeats: true)
}

struct State: Equatable {
	let title: String
	let count: Int
	let flip: Bool
}

func ==(lhs: State, rhs: State) -> Bool {
	return lhs.title == rhs.title && lhs.count == rhs.count && lhs.flip == rhs.flip
}

let initialState = State(title: "Hi!", count: 1, flip: false)

func render(state: State) -> Element<State> {
	if state.flip {
		return Input()
	} else {
		return Button(frame: CGRect(x: 0, y: 0, width: 50 + state.count, height: 23), title: state.title + " \(state.count)")
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
