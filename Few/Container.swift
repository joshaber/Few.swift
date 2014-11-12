//
//  Container.swift
//  Few
//
//  Created by Josh Abernathy on 8/27/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import AppKit

/// Containers (surprise!) contain other elements.
///
/// They diff their children using essentially two different passes:
///   1. Pair up children with the same key and diff them if possible.
///   2. Diff remaining children by order.
public class Container: Element {
	private let children: [Element]

	private let layout: ((Container, [Element]) -> ())?

	public init(children: [Element], layout: ((Container, [Element]) -> ())?) {
		self.layout = layout
		self.children = children
		super.init()
		self.sizingBehavior = .None
	}

	public convenience init(_ children: [Element]) {
		self.init(children: children, nil)
	}

	public convenience init(_ children: Element...) {
		self.init(children)
	}

	// MARK: Element

	public override func applyDiff(view: ViewType, other: Element) {
		super.applyDiff(view, other: other)

		layout?(self, children)
	}

	public override func realize() -> ViewType? {
		return NSView(frame: frame)
	}

	public override func derealize() {
		for element in children {
			element.derealize()
		}
		
		super.derealize()
	}

	public override func getChildren() -> [Element] {
		return children
	}
}

public func noLayout(container: Container, elements: [Element]) {}

public func alignLefts(origin: CGFloat)(container: Container, elements: [Element]) {
	for el in elements {
		el.frame.origin.x = origin
	}
}

public func verticalStack(padding: CGFloat)(container: Container, elements: [Element]) {
	var y = container.frame.size.height - padding;
	for el in elements {
		y -= el.frame.size.height + padding
		el.frame.origin.y = y
	}
}

public func horizontalStack(padding: CGFloat)(container: Container, elements: [Element]) {
	var x = padding
	for el in elements {
		el.frame.origin.x = x
		x += el.frame.size.width + padding
	}
}

public func offset(amount: CGPoint)(container: Container, elements: [Element]) {
	for el in elements {
		el.frame = CGRectOffset(el.frame, amount.x, amount.y)
	}
}

infix operator >-- { associativity left }
public func >--(f: (Container, [Element]) -> (), g: (Container, [Element]) -> ()) -> ((Container, [Element]) -> ()) {
	return { container, elements in
		f(container, elements)
		g(container, elements)
	}
}
