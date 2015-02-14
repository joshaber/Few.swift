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
	public let view: ViewType
	internal var children: [RealizedElement] = []

	public init(element: Element, view: ViewType) {
		self.element = element
		self.view = view
	}

	public func addRealizedChild(child: RealizedElement, index: Int?) {
		if let index = index {
			children.insert(child, atIndex: index)
		} else {
			children.append(child)
		}

		element.addRealizedChildView(child.view, selfView: view)
	}

	public func removeRealizedChild(child: RealizedElement) {
		child.view.removeFromSuperview()

		if let index = indexOfObject(children, child) {
			children.removeAtIndex(index)
		}
	}
}
