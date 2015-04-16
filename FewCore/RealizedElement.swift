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
	public var view: ViewType?
	internal var children: [RealizedElement] = []
	public weak var parent: RealizedElement?

	public init(element: Element, view: ViewType?) {
		self.element = element
		self.view = view
	}

	public func addRealizedChild(child: RealizedElement, index: Int?) {
		child.parent = self

		if let index = index {
			children.insert(child, atIndex: index)
		} else {
			children.append(child)
		}

		addRealizedViewForChild(child)
	}

	public func parentViewWithView() -> ViewType? {
		if view != nil { return view }

		return parent?.parentViewWithView()
	}

	public func addRealizedViewForChild(child: RealizedElement) {
		if let childView = child.view {
			child.assembleNewViewHierarchy(parentViewWithView())
		}
	}

	public func remove() {
		for child in children {
			child.remove()
		}

		view?.removeFromSuperview()
		element.derealize()

		if let parent = parent {
			parent.removeRealizedChild(self)
		}

		parent = nil
	}

	private func removeRealizedChild(child: RealizedElement) {
		if let index = indexOfObject(children, child) {
			children.removeAtIndex(index)
		}
	}

	public func assembleNewViewHierarchy(parentView: ViewType?, offset: CGPoint = CGPointZero) {
		if parentView == nil && view == nil {
			println("creating view for \(element)")
			view = ViewType(frame: element.viewFrame)
		} else if parentView != nil {
			view?.frame.origin.x += offset.x
			view?.frame.origin.y += offset.y
			parentView!.addSubview <^> view
		}

		for child in children {
			var parentViewForChild = view ?? parentView
			var offset = (view != nil ? CGPointZero : CGPoint(x: offset.x + element.frame.origin.x, y: offset.y + element.frame.origin.y))
			child.assembleNewViewHierarchy(parentViewForChild, offset: offset)
		}
	}
}
