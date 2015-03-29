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

internal func compareAndSetAlpha(view: NSView, alpha: CGFloat) {
	if fabs(view.alphaValue - alpha) > CGFloat(DBL_EPSILON) {
		view.alphaValue = alpha
	}
}

internal func markNeedsDisplay(view: ViewType) {
	view.needsDisplay = true
}

internal func configureViewToAutoresize(view: ViewType?) {
	view?.autoresizingMask = .ViewWidthSizable | .ViewHeightSizable
}
