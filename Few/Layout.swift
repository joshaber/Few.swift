//
//  Layout.swift
//  Few
//
//  Created by Josh Abernathy on 8/11/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import AppKit

public func absolute(element: Element, frame: CGRect) -> Layout {
	return Layout(element: element, fn: const(frame))
}

public func sized(element: Element, size: CGSize) -> Layout {
	return Layout(element: element) { element in
		CGRect(origin: element.frame.origin, size: size)
	}
}

public func absolute(element: Element, origin: CGPoint) -> Layout {
	return Layout(element: element) { element in
		CGRect(origin: origin, size: element.frame.size)
	}
}

public func absolute(origin: CGPoint)(element: Element) -> Layout {
	return absolute(element, origin)
}

public func sized(size: CGSize)(element: Element) -> Layout {
	return sized(element, size)
}

public func sizeToFit(element: Element) -> Layout {
	return Layout(element: element) { element in
		let size = element.getIntrinsicSize()
		return CGRect(origin: element.frame.origin, size: size)
	}
}

public func offset(element: Element, dx: CGFloat, dy: CGFloat) -> Layout {
	return Layout(element: element) { element in
		CGRectOffset(element.frame, dx, dy)
	}
}

public func offset(dx: CGFloat, dy: CGFloat)(element: Element) -> Layout {
	return offset(element, dx, dy)
}

public func |>(left: Element, right: Element) -> Layout {
	return Layout(element: right) { element in
		CGRect(x: CGRectGetMaxX(left.frame), y: CGRectGetMidY(left.frame), width: right.frame.width, height: right.frame.height)
	}
}

public class Layout: Element {
	private var element: Element

	private var layoutFn: Element -> CGRect
	
	private var parentView: NSView?

	public init(element: Element, fn: Element -> CGRect) {
		self.element = element
		self.layoutFn = fn
	}
	
	public override func applyLayout(fn: Element -> CGRect) {
		element.applyLayout(fn)
	}

	private func layoutElements() {
		element.applyLayout(layoutFn)
	}

	// MARK: Element
	
	public override func canDiff(other: Element) -> Bool {
		if !super.canDiff(other) { return false }
		
		let otherLayout = other as Layout
		return element.canDiff(otherLayout.element)
	}

	public override func applyDiff(other: Element) {
		let otherLayout = other as Layout
		element.applyDiff(otherLayout.element)

		layoutFn = otherLayout.layoutFn

		super.applyDiff(other)

		layoutElements()
	}

	public override func realize<S>(component: Component<S>, parentView: NSView) {
		self.parentView = parentView
		
		element.realize(component, parentView: parentView)

		super.realize(component, parentView: parentView)
		
		layoutElements()
	}

	public override func derealize() {
		element.derealize()
	}
	
	public override func getContentView() -> NSView? {
		return element.getContentView()
	}
}
