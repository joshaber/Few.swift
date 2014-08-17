//
//  Siblings.swift
//  Few
//
//  Created by Josh Abernathy on 8/8/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import AppKit

public func +<S>(left: Element<S>, right: Element<S>) -> Element<S> {
	return Siblings(left, right)
}

public class Siblings<S: Equatable>: Element<S> {
	private var left: Element<S>
	private var right: Element<S>

	private weak var component: Component<S>?
	private var parentView: NSView?

	public init(_ left: Element<S>, _ right: Element<S>) {
		self.left = left
		self.right = right
	}

	// MARK: Element
	
	public override func applyLayout(fn: Element<S> -> CGRect) {
		for element in [left, right] {
			element.applyLayout(fn)
		}
	}

	public override func realize(component: Component<S>, parentView: NSView) {
		self.component = component
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
	
	private func diffSiblings(inout ours: Element<S>, theirs: Element<S>) {
		if ours.canDiff(theirs) {
			ours.applyDiff(theirs)
		} else {
			ours.derealize()
			ours = theirs
			curry(ours.realize) <^> component <*> parentView
		}
	}

	public override func applyDiff(other: Element<S>) {
		let otherSiblings = other as Siblings
		
		diffSiblings(&left, theirs: otherSiblings.left)
		diffSiblings(&right, theirs: otherSiblings.right)

		super.applyDiff(other)
	}
}
