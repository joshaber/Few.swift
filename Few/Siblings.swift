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
	private let siblings: [Element<S>]

	private weak var component: Component<S>?
	private var parentView: NSView?

	public init(_ siblings: [Element<S>]) {
		self.siblings = siblings
	}

	convenience public init(_ siblings: Element<S>...) {
		self.init(siblings)
	}

	// MARK: Element

	public override func realize(component: Component<S>, parentView: NSView) {
		self.component = component
		self.parentView = parentView

		// Iterate in reverse so that objects in the front of the array are 
		// visually in front of objects towards the back of the array.
		for element in siblings.reverse() {
			element.realize(component, parentView: parentView)
		}
	}

	public override func derealize() {
		for element in siblings {
			element.derealize()
		}
	}

	public override func applyDiff(other: Element<S>) {
		let otherSiblings = other as Siblings
		for pair in Zip2(siblings, otherSiblings.siblings) {
			if (pair.0.canDiff(pair.1)) {
				pair.0.applyDiff(pair.1)
			} else {
				pair.0.derealize()
				if let component = component {
					if let parentView = parentView {
						pair.1.realize(component, parentView: parentView)
					}
				}
			}
		}
	}
}
