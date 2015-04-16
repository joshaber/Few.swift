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
		// HAHA SWIFT WHY DOES POINTER EQUALITY NOT WORK
		let ptr1 = Unmanaged<T>.passUnretained(element).toOpaque()
		let ptr2 = Unmanaged<T>.passUnretained(e).toOpaque()
		if ptr1 == ptr2 { return i }
	}

	return nil
}

public class RealizedElement {
	public var element: Element
	public let view: ViewType?
	internal var children: [RealizedElement] = []
	public weak var parent: RealizedElement?
	internal var frameOffset = CGPointZero

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
		if child.view == nil { return }

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

	private func removeRealizedChild(child: RealizedElement) {
		if let index = indexOfObject(children, child) {
			children.removeAtIndex(index)
		}
	}
}
