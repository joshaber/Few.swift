//
//  Siblings.swift
//  Few
//
//  Created by Josh Abernathy on 1/25/15.
//  Copyright (c) 2015 Josh Abernathy. All rights reserved.
//

import Cocoa

public func +(left: Element, right: Element) -> Element {
	return Siblings(left, right)
}

public class Siblings: Element {
	private let child1: Element
	private let child2: Element

	public init(_ child1: Element, _ child2: Element) {
		self.child1 = child1
		self.child2 = child2
		super.init(frame: CGRectUnion(child1.frame, child2.frame))
	}

	public required init(copy: Element, frame: CGRect, hidden: Bool, alpha: CGFloat, key: String?) {
		let container = copy as Siblings
		child1 = container.child1
		child2 = container.child2
		super.init(copy: copy, frame: frame, hidden: hidden, alpha: alpha, key: key)
	}

	// MARK: Element

	public override func getChildren() -> [Element] {
		return [ child1, child2 ]
	}
}
