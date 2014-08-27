//
//  Element.swift
//  Few
//
//  Created by Josh Abernathy on 7/22/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import AppKit

public func empty() -> Element {
	return fillRect(NSColor.clearColor())
}

public class Element {
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
	
	public weak var component: Component<Any>?
	
	public init() {}
	
	public func applyLayout(fn: Element -> CGRect) {
		frame = fn(self)
	}

	/// Can the receiver and the other element be diffed?
	///
	/// The default implementation checks the dynamic types of both objects and
	/// returns `true` only if they are identical. This will be good enough for
	/// most cases.
	public func canDiff(other: Element) -> Bool {
		return other.dynamicType === self.dynamicType
	}

	/// Apply the diff. The receiver should take on any differences between it
	/// and `other`.
	///
	/// This will only be called if `canDiff` returns `true`. Implementations 
	/// should call super.
	public func applyDiff(other: Element) {
		
	}

	/// Realize the element in the given component and parent view.
	///
	/// The default implementation adds the content view to `parentView`.
	public func realize<S>(component: Component<S>, parentView: NSView) {
		// Ugh. This shouldn't be necessary.
		self.component = unsafeBitCast(component, Component<Any>.self)

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
