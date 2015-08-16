//
//  Layout+View.swift
//  SwiftBox
//
//  Created by Josh Abernathy on 2/1/15.
//  Copyright (c) 2015 Josh Abernathy. All rights reserved.
//

import Foundation

#if os(iOS)
	import UIKit
	public typealias ViewType = UIView
#else
	import AppKit
	public typealias ViewType = NSView
#endif

extension Layout {
	/// Apply the layout to the given view hierarchy.
	public func apply(view: ViewType) {
		view.frame = CGRectIntegral(frame)

		for (s, layout) in zip(view.subviews, children) {
			let subview = s as ViewType
			layout.apply(subview)
		}
	}
}
