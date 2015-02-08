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

	// On OS X we have to reverse our children since the default coordinate 
	// system is flipped.
#if os(OSX)
	public var children: [Element] {
		didSet {
			if direction == .Column {
				children = children.reverse()
			}
		}
	}
#else
	public var children: [Element]
#endif

#if os(OSX)
	public var direction: Direction {
		didSet {
			if direction != oldValue && direction == .Column {
				children = children.reverse()
			}
		}
	}
#else
	public var direction: Direction
#endif

	public var margin: Edges
	public var padding: Edges
	public var wrap: Bool
	public var justification: Justification
	public var selfAlignment: SelfAlignment
	public var childAlignment: ChildAlignment
	public var flex: CGFloat

	internal var view: ViewType?

	public init(frame: CGRect = CGRect(x: 0, y: 0, width: Node.Undefined, height: Node.Undefined), key: String? = nil, hidden: Bool = false, alpha: CGFloat = 1, children: [Element] = [], direction: Direction = .Row, margin: Edges = Edges(), padding: Edges = Edges(), wrap: Bool = false, justification: Justification = .FlexStart, selfAlignment: SelfAlignment = .Auto, childAlignment: ChildAlignment = .Stretch, flex: CGFloat = 0) {
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
	public func applyDiff(old: Element) {
		if LogDiff {
			println("*** Diffing \(reflect(self).summary)")
		}

		self.view = old.view

		if let view = view {
			if view.frame != frame {
				view.frame = frame
			}

			if view.hidden != hidden {
				view.hidden = hidden
			}

			if fabs(view.alphaValue - alpha) > CGFloat(DBL_EPSILON) {
				view.alphaValue = alpha
			}
		}

		let listDiff = diffElementLists(old.children, children)

		for child in listDiff.add {
			child.realize()
			addRealizedChild(child)
		}

		for child in listDiff.diff {
			child.`new`.applyDiff(child.old)
		}

		for child in listDiff.remove {
			child.derealize()
		}
	}

	public func createView() -> ViewType {
		return ViewType(frame: frame)
	}

	/// Realize the element.
	public func realize() {
		let view = createView()
		view.frame = frame
		self.view = view

		for child in children {
			child.realize()
			addRealizedChild(child)
		}
	}

	internal func addRealizedChild(child: Element) {
		view!.addSubview(child.view!)
	}

	/// Derealize the element.
	public func derealize() {
		for child in children {
			child.derealize()
		}

		view?.removeFromSuperview()
		view = nil
	}

	internal func assembleLayoutNode() -> Node {
		let childNodes = children.map { $0.assembleLayoutNode() }
		return Node(size: frame.size, children: childNodes, direction: direction, margin: margin, padding: padding, wrap: wrap, justification: justification, selfAlignment: selfAlignment, childAlignment: childAlignment, flex: flex)
	}

	internal func applyLayout(layout: Layout) {
		frame = CGRectIntegral(layout.frame)

		for (child, layout) in Zip2(children, layout.children) {
			child.applyLayout(layout)
		}
	}
}

extension Element {
	public func size(width: CGFloat, _ height: CGFloat) -> Self {
		frame.size.width = width
		frame.size.height = height
		return self
	}

	public func margin(edges: Edges) -> Self {
		margin = edges
		return self
	}

	public func padding(edges: Edges) -> Self {
		padding = edges
		return self
	}

	public func selfAlignment(alignment: SelfAlignment) -> Self {
		selfAlignment = alignment
		return self
	}

	public func direction(d: Direction) -> Self {
		direction = d
		return self
	}

	public func wrap(w: Bool) -> Self {
		wrap = w
		return self
	}

	public func justification(j: Justification) -> Self {
		justification = j
		return self
	}

	public func childAlignment(alignment: ChildAlignment) -> Self {
		childAlignment = alignment
		return self
	}

	public func flex(f: CGFloat) -> Self {
		flex = f
		return self
	}

	public func frame(f: CGRect) -> Self {
		frame = f
		return self
	}

	public func hidden(h: Bool) -> Self {
		hidden = h
		return self
	}

	public func children(c: [Element]) -> Self {
		children = c
		return self
	}

	public func alpha(a: CGFloat) -> Self {
		alpha = a
		return self
	}
}
