//
//  Layout.swift
//  Few
//
//  Created by Josh Abernathy on 8/11/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import AppKit

public func absolute<S>(element: Element<S>, frame: CGRect) -> Layout<S> {
	return Layout(element: element, fn: const(frame))
}

public func absolute<S>(element: Element<S>, size: CGSize) -> Layout<S> {
	return Layout(element: element) { element in
		CGRect(origin: element.frame.origin, size: size)
	}
}

public func absolute<S>(element: Element<S>, origin: CGPoint) -> Layout<S> {
	return Layout(element: element) { element in
		CGRect(origin: origin, size: element.frame.size)
	}
}

public func absolute<S>(origin: CGPoint)(element: Element<S>) -> Layout<S> {
	return absolute(element, origin)
}

public func sizeToFit<S>(element: Element<S>) -> Layout<S> {
	return Layout(element: element) { element in
		let size = element.getIntrinsicSize()
		return CGRect(origin: element.frame.origin, size: size)
	}
}

public func offset<S>(element: Element<S>, dx: CGFloat, dy: CGFloat) -> Layout<S> {
	return Layout(element: element) { element in
		CGRectOffset(element.frame, dx, dy)
	}
}

public func offset<S>(dx: CGFloat, dy: CGFloat)(element: Element<S>) -> Layout<S> {
	return offset(element, dx, dy)
}

public func |><S>(left: Element<S>, right: Element<S>) -> Layout<S> {
	return Layout(element: right) { element in
		CGRect(x: CGRectGetMaxX(left.frame), y: CGRectGetMidY(left.frame), width: right.frame.width, height: right.frame.height)
	}
}

public class Layout<S>: Element<S> {
	private var element: Element<S>

	private var layoutFn: Element<S> -> CGRect
	
	private weak var component: Component<S>?
	private var parentView: NSView?

	public init(element: Element<S>, fn: Element<S> -> CGRect) {
		self.element = element
		self.layoutFn = fn
	}
	
	public override func applyLayout(fn: Element<S> -> CGRect) {
		element.applyLayout(fn)
	}

	private func layoutElements() {
		element.applyLayout(layoutFn)
	}

	// MARK: Element
	
	public override func canDiff(other: Element<S>) -> Bool {
		if !super.canDiff(other) { return false }
		
		let otherLayout = other as Layout<S>
		return element.canDiff(otherLayout.element)
	}

	public override func applyDiff(other: Element<S>) {
		let otherLayout = other as Layout<S>
		element.applyDiff(otherLayout.element)

		layoutFn = otherLayout.layoutFn

		super.applyDiff(other)

		layoutElements()
	}

	public override func realize(component: Component<S>, parentView: NSView) {
		self.component = component
		self.parentView = parentView
		
		element.realize(component, parentView: parentView)

		super.realize(component, parentView: parentView)
		
		layoutElements()
	}

	public override func derealize() {
		element.derealize()
	}
}
