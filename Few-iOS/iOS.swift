//
//  iOS.swift
//  Few
//
//  Created by Josh Abernathy on 12/20/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import UIKit

public typealias ViewType = UIView

public typealias ColorType = UIColor

internal func withAnimation(duration: NSTimeInterval, timingFunction: TimingFunction, fn: () -> ()) {
	UIView.animateWithDuration(duration) {
		// TODO iOS: use timing function
		fn()
	}
}

internal func animatorProxy<T: UIView>(view: T) -> T {
	return view
}

internal func compareAndSetAlpha(view: UIView, alpha: CGFloat) {
	if fabs(view.alpha - alpha) > CGFloat(DBL_EPSILON) {
		view.alpha = alpha
	}
}
