//
//  Element.swift
//  Few
//
//  Created by Josh Abernathy on 7/22/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import AppKit

public func empty<S>() -> Element<S> {
	return fillRect(NSColor.clearColor())
}

public class Element<S> {
	internal var modelFrame = CGRectZero
	public var frame: CGRect {
		get {
			return getContentView()?.frame ?? modelFrame
		}

		set {
			modelFrame = newValue

			if let view = getContentView() {
				view.frame = newValue
			}
		}
	}
	
	public init() {}
	
	public func applyLayout(fn: Element<S> -> CGRect) {
		frame = fn(self)
	}

	/// Can the receiver and the other element be diffed?
	///
	/// The default implementation checks the dynamic types of both objects and
	/// returns `true` only if they are identical. This will be good enough for
	/// most cases.
	public func canDiff(other: Element<S>) -> Bool {
		return other.dynamicType === self.dynamicType
	}

	/// Apply the diff. The receiver should take on any differences between it
	/// and `other`.
	///
	/// This will only be called if `canDiff` returns `true`. Implementations 
	/// should call super.
	public func applyDiff(other: Element<S>) {
		
	}

	/// Realize the element in the given component and parent view.
	///
	/// The default implementation adds the content view to `parentView`.
	public func realize(component: Component<S>, parentView: NSView) {
		parentView.addSubview <^> getContentView()
	}

	/// Derealize the element.
	///
	/// The default implemetation removes the content view from its superview.
	public func derealize() {
		getContentView()?.removeFromSuperview()
	}

	/// Get the content view which represents the element.
	public func getContentView() -> NSView? {
		return nil
	}
	
	public func getIntrinsicSize() -> CGSize {
		return CGSizeZero
	}
}
