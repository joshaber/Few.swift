//
//  Element.swift
//  Few
//
//  Created by Josh Abernathy on 7/22/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import CoreGraphics
import SwiftBox

public var LogDiff = false

/// Elements are the basic building block. They represent a visual thing which 
/// can be diffed with other elements.
public class Element {
	/// The frame of the element.
	public var frame = CGRectZero

	/// The key used to identify the element. Elements with matching keys will 
	/// be more readily diffed in certain situations (i.e., when in a Container
	/// or List).
	//
	// TODO: This doesn't *really* need to be a string. Just hashable and 
	// equatable.
	public var key: String?

	/// Is the element hidden?
	public var hidden: Bool = false

	/// The alpha for the element.
	public var alpha: CGFloat = 1

	public var children: [Element]
	public var direction: Direction
	public var margin: Edges
	public var padding: Edges
	public var wrap: Bool
	public var justification: Justification
	public var selfAlignment: SelfAlignment
	public var childAlignment: ChildAlignment
	public var flex: CGFloat

	public init(frame: CGRect = CGRectZero, key: String? = nil, hidden: Bool = false, alpha: CGFloat = 1, children: [Element] = [], direction: Direction = .Row, margin: Edges = Edges(), padding: Edges = Edges(), wrap: Bool = false, justification: Justification = .FlexStart, selfAlignment: SelfAlignment = .Auto, childAlignment: ChildAlignment = .Stretch, flex: CGFloat = 0) {
		self.frame = frame
		self.key = key
		self.hidden = hidden
		self.alpha = alpha
		self.children = children
		self.direction = direction
		self.margin = margin
		self.padding = padding
		self.wrap = wrap
		self.justification = justification
		self.selfAlignment = selfAlignment
		self.childAlignment = childAlignment
		self.flex = flex
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
			view.frame = frame
		}

		if view.hidden != hidden {
			view.hidden = hidden
		}

		if fabs(view.alphaValue - alpha) > CGFloat(DBL_EPSILON) {
			view.alphaValue = alpha
		}

		if LogDiff {
			println("** Diffing \(reflect(self).summary)")
		}
	}

	/// Realize the element and return the view containing it.
	public func realize() -> ViewType? {
		return ViewType(frame: frame)
	}

	/// Derealize the element.
	public func derealize() {
		for child in children {
			child.derealize()
		}
	}

	internal func elementDidRealize() {
		for child in children {
			child.elementDidRealize()
		}
	}

	internal func assembleLayoutNode() -> Node {
		let childNodes = children.map { $0.assembleLayoutNode() }
		return Node(size: frame.size, children: childNodes, direction: direction, margin: margin, padding: padding, wrap: wrap, justification: justification, selfAlignment: selfAlignment, childAlignment: childAlignment, flex: flex)
	}
}
