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
	public weak var parent: RealizedElement?
	internal var children: [RealizedElement] = []

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

		var hostView = view
		if hostView == nil {
			hostView = findParentWithView()?.view
			if let childView = child.view {
				child.view?.frame = frameRelativeToParent(self, frame: childView.frame)
			}
		}

		element.addRealizedChildView(child.view, selfView: hostView)
	}

	public func removeRealizedChild(child: RealizedElement) {
		child.parent = nil
		child.view?.removeFromSuperview()

		if let index = indexOfObject(children, child) {
			children.removeAtIndex(index)
		}
	}

	public func findParentWithView() -> RealizedElement? {
		var currentParent = parent
		while currentParent != nil {
			if currentParent?.view != nil { return currentParent }
			currentParent = currentParent?.parent
		}

		return nil
	}

	public func frameRelativeToParent(destinationParent: RealizedElement, frame: CGRect) -> CGRect {
		var currentParent = parent
		var translatedFrame = frame
		while currentParent !== destinationParent {
			translatedFrame.origin.x += currentParent?.element.frame.origin.x ?? 0
			translatedFrame.origin.y += currentParent?.element.frame.origin.y ?? 0
		}

		return translatedFrame
	}
}
