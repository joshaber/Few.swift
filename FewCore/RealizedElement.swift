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

	private var layoutFrame: CGRect
	private var needsLayout = true

	public init(element: Element, view: ViewType?, parent: RealizedElement?) {
		self.element = element
		self.view = view
		self.parent = parent
		layoutFrame = element.frame
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

		let viewParent = child.findViewParent()
		viewParent?.view?.addSubview(child.view!)
		child.element.elementDidRealize(child)
	}

	private func findViewParent() -> RealizedElement? {
		var currentParent: RealizedElement? = parent
		while let p = currentParent {
			if p.view != nil { return p }
			currentParent = p.parent
		}

		return nil
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

		if let parent = parent where !parent.needsLayout {
			parent.markNeedsLayout()
		}
	}

	public final func layoutIfNeeded(maxWidth: CGFloat) {
		if !needsLayout { return }

		let node = element.assembleLayoutNode()
		let layout = node.layout(maxWidth: maxWidth)

		applyLayout(layout, offset: CGPointZero)
	}

	internal func realizedElementForElement(element: Element) -> RealizedElement? {
		for child in children {
			if child.element === element {
				return child
			}
		}

		return nil
	}

	internal func layoutFromRoot() {
		if let root = findRoot() {
			if root.element.isRendering && root !== self { return }

			root.layoutIfNeeded(root.element.frame.size.width)
		} else {
			layoutIfNeeded(element.frame.size.width)
		}
	}

	internal final func findRoot() -> RealizedElement? {
		if element.isRoot {
			return self
		} else {
			return parent?.findRoot()
		}
	}

	private final func applyLayout(layout: Layout, offset: CGPoint) {
		layoutFrame = layout.frame.rectByOffsetting(dx: offset.x, dy: offset.y)

		let childOffset: CGPoint
		if let view = view {
			// If we have a view then children won't need to be offset at all.
			childOffset = CGPointZero
			view.frame = layoutFrame.integerRect
		} else {
			childOffset = layoutFrame.origin
		}

		for (child, layout) in Zip2(children, layout.children) {
			child.applyLayout(layout, offset: childOffset)
		}

		element.elementDidLayout(self)

		needsLayout = false
	}
}
