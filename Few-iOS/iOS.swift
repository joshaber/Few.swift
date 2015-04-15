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

internal func compareAndSetAlpha(view: UIView, alpha: CGFloat) {
	if fabs(view.alpha - alpha) > CGFloat(DBL_EPSILON) {
		view.alpha = alpha
	}
}

internal func configureViewToAutoresize(view: ViewType?) {
	view?.autoresizingMask = .FlexibleWidth | .FlexibleHeight
}
