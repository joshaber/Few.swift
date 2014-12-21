//
//  Element.swift
//  Few
//
//  Created by Josh Abernathy on 7/22/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import CoreGraphics

public var LogDiff = false

/// Elements are the basic building block. They represent a visual thing which 
/// can be diffed with other elements.
public class Element {
	/// The frame of the element.
	public let frame = CGRectZero

	/// The key used to identify the element. Elements with matching keys will 
	/// be more readily diffed in certain situations (i.e., when in a Container
	/// or List).
	//
	// TODO: This doesn't *really* need to be a string. Just hashable and 
	// equatable.
	public let key: String?

	/// Is the element hidden?
	public let hidden: Bool = false

	public let alpha: CGFloat = 1

	public init(frame: CGRect = CGRectZero, key: String? = nil, hidden: Bool = false, alpha: CGFloat = 1) {
		self.frame = frame
		self.key = key
		self.hidden = hidden
		self.alpha = alpha
	}

	public required init(copy: Element, frame: CGRect, hidden: Bool, alpha: CGFloat, key: String?) {
		self.frame = frame
		self.hidden = hidden
		self.key = key
		self.alpha = alpha
	}

	/// Can the receiver and the other element be diffed?
	///
	/// The default implementation checks the dynamic types of both objects and
	/// returns `true` only if they are identical. This will be good enough for
	/// most cases.
	public func canDiff(other: Element) -> Bool {
		return other.dynamicType === self.dynamicType
	}

	/// Apply the diff. The receiver is the latest version and the argument is
	/// the previous version. This usually entails updating the properties of 
	/// the given view when they are different from the properties of the 
	/// receiver.
	///
	/// This will be called as part of the render process, and also immediately
	/// after the element has been realized.
	///
	/// This will only be called if `canDiff` returns `true`. Implementations
	/// should call super.
	public func applyDiff(view: ViewType, other: Element) {
		if view.frame != frame {
			animatorProxy(view).frame = frame
		}

		if view.hidden != hidden {
			view.hidden = hidden
		}

		compareAndSetAlpha(view, alpha)

		if LogDiff {
			println("** Diffing \(reflect(self).summary)")
		}
	}

	/// Realize the element and return the view containing it.
	public func realize() -> ViewType? {
		return nil
	}

	/// Derealize the element.
	public func derealize() {}

	/// Get the children of the element.
	public func getChildren() -> [Element] {
		return []
	}

	public func hidden(h: Bool) -> Self {
		return self.dynamicType(copy: self, frame: frame, hidden: h, alpha: alpha, key: key)
	}

	public func frame(f: CGRect) -> Self {
		return self.dynamicType(copy: self, frame: f, hidden: hidden, alpha: alpha, key: key)
	}

	public func key(k: String) -> Self {
		return self.dynamicType(copy: self, frame: frame, hidden: hidden, alpha: alpha, key: k)
	}

	public func alpha(a: CGFloat) -> Self {
		return self.dynamicType(copy: self, frame: frame, hidden: hidden, alpha: a, key: key)
	}
}

extension Element {
	public func hide() -> Self {
		return hidden(true)
	}

	public func show() -> Self {
		return hidden(false)
	}
}

extension Element {
	public func width(w: CGFloat) -> Self {
		return frame(CGRect(x: frame.origin.x, y: frame.origin.y, width: w, height: frame.size.height))
	}

	public func height(h: CGFloat) -> Self {
		return frame(CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: h))
	}

	public func x(x: CGFloat) -> Self {
		return frame(CGRect(x: x, y: frame.origin.y, width: frame.size.width, height: frame.size.height))
	}

	public func y(y: CGFloat) -> Self {
		return frame(CGRect(x: frame.origin.x, y: y, width: frame.size.width, height: frame.size.height))
	}
}
