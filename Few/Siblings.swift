//
//  Siblings.swift
//  Few
//
//  Created by Josh Abernathy on 8/8/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import AppKit

public func +(left: Element, right: Element) -> Element {
	return Siblings(left, right)
}

public class Siblings: Element {
	private var left: Element
	private var right: Element

	private var parentView: NSView?

	public init(_ left: Element, _ right: Element) {
		self.left = left
		self.right = right
	}

	// MARK: Element
	
	public override func applyLayout(fn: Element -> CGRect) {
		for element in [left, right] {
			element.applyLayout(fn)
		}
	}

	public override func realize<S>(component: Component<S>, parentView: NSView) {
		self.parentView = parentView

		left.realize(component, parentView: parentView)
		right.realize(component, parentView: parentView)

		super.realize(component, parentView: parentView)
	}

	public override func derealize() {
		left.derealize()
		right.derealize()

		super.derealize()
	}
	
	private func diffSiblings(inout ours: Element, theirs: Element) {
		if ours.canDiff(theirs) {
			ours.applyDiff(theirs)
		} else {
			ours.derealize()
			ours = theirs
			curry(ours.realize) <^> component <*> parentView
		}
	}

	public override func applyDiff(other: Element) {
		let otherSiblings = other as Siblings
		
		diffSiblings(&left, theirs: otherSiblings.left)
		diffSiblings(&right, theirs: otherSiblings.right)

		super.applyDiff(other)
	}
}
