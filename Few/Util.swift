//
//  Util.swift
//  Few
//
//  Created by Josh Abernathy on 8/6/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation

func every(interval: NSTimeInterval, fn: () -> ()) -> NSTimer {
	let timerTrampoline = TargetActionTrampoline()
	timerTrampoline.action = fn
	return NSTimer.scheduledTimerWithTimeInterval(interval, target: timerTrampoline, selector: timerTrampoline.selector, userInfo: nil, repeats: true)
}

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
