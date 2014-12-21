//
//  Mac.swift
//  Few
//
//  Created by Josh Abernathy on 12/17/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import AppKit

public typealias ViewType = NSView

public typealias ColorType = NSColor

internal func withAnimation(duration: NSTimeInterval, timingFunction: TimingFunction, fn: () -> ()) {
	NSAnimationContext.runAnimationGroup({ context in
		context.duration = duration
		context.timingFunction = timingFunction.mediaTimingFunction
		fn()
	}, completionHandler: nil)
}

internal func animatorProxy<T: NSView>(view: T) -> T {
	if Animating {
		return view.animator()
	} else {
		return view
	}
}

internal func compareAndSetAlpha(view: NSView, alpha: CGFloat) {
	if fabs(view.alphaValue - alpha) > CGFloat(DBL_EPSILON) {
		animatorProxy(view).alphaValue = alpha
	}
}
