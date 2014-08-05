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

func render(state: State) -> Element<State, Observable<State>> {
	if state.flip {
		return Input()
	} else {
		let frame = CGRect(x: 0, y: 0, width: 50 + state.count, height: 23)
		let title = state.title + " \(state.count)"
		return Button(frame: frame, title: title, fn: const(initialState))
	}
}

class AppDelegate: NSObject, NSApplicationDelegate {
	@IBOutlet weak var window: NSWindow!

	private let component = Component(render: render, initialState: initialState)

	func applicationDidFinishLaunching(notification: NSNotification?) {
		let contentView = window.contentView as NSView
		component.addToView(contentView)

		every(0.1) {
			let state = self.component.state.value
			var newFlip = state.flip
			if state.count % 20 == 0 {
				newFlip = !state.flip
			}

			self.component.state.value = State(title: state.title, count: state.count + 1, flip: newFlip)
		}
	}
}
