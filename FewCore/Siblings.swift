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

internal class Siblings: Element {
	internal init(_ child1: Element, _ child2: Element) {
		super.init(frame: CGRectUnion(child1.frame, child2.frame), children: [ child1, child2 ])
	}
}
