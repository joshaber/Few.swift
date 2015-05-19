//
//  RealizedElement.swift
//  Few
//
//  Created by Josh Abernathy on 2/13/15.
//  Copyright (c) 2015 Josh Abernathy. All rights reserved.
//

import Foundation

internal func indexOfObject<T: AnyObject>(array: [T], element: T) -> Int? {
	for (i, e) in enumerate(array) {
		if element === e { return i }
	}

	return nil
}

public class RealizedElement {
	public var element: Element
	public let view: ViewType?
	public weak var parent: RealizedElement?

	internal var children: [RealizedElement] = []
	private var frameOffset = CGPointZero

	internal var needsLayout = true

	public init(element: Element, view: ViewType?, parent: RealizedElement?) {
		self.element = element
		self.view = view
		self.parent = parent
	}

	public func addRealizedChild(child: RealizedElement, index: Int?) {
		if let index = index {
			children.insert(child, atIndex: index)
		} else {
			children.append(child)
		}

		addRealizedViewForChild(child)
	}

	public func addRealizedViewForChild(child: RealizedElement) {
		if child.view == nil {
			child.element.elementDidRealize(child)
			return
		}

		var parent: RealizedElement? = self
		var offset = CGPointZero
		while let currentParent = parent {
			if currentParent.view != nil { break }

			offset.x += currentParent.element.frame.origin.x + currentParent.frameOffset.x
			offset.y += currentParent.element.frame.origin.y + currentParent.frameOffset.y
			parent = currentParent.parent
		}

		child.view?.frame.origin.x += offset.x
		child.view?.frame.origin.y += offset.y
		child.frameOffset = offset
		parent?.view?.addSubview(child.view!)
		child.element.elementDidRealize(child)
	}

	public func remove() {
		for child in children {
			child.remove()
		}

		view?.removeFromSuperview()
		element.derealize()

		parent?.removeRealizedChild(self)
		parent = nil
	}

	private final func removeRealizedChild(child: RealizedElement) {
		if let index = indexOfObject(children, child) {
			children.removeAtIndex(index)
		}
	}

	public final func markNeedsLayout() {
		needsLayout = true

		parent?.markNeedsLayout()
	}

	public final func layoutIfNeeded(maxWidth: CGFloat) {
		if !needsLayout { return }

		let node = element.assembleLayoutNode()
		let layout = node.layout(maxWidth: maxWidth)

		element.applyLayout(layout)
	}
}
