//
//  Flow.swift
//  Few
//
//  Created by Josh Abernathy on 8/5/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import AppKit

//infix operator <+> { associativity right }
//public func <+><S>(l: Element<S>, r: Element<S>) -> Element<S> {
//	return Flow(l, r)
//}

// TODO: It'd be nice to put this into Flow, but clang crashes in b5 :(
public enum Direction {
	case Down
}

public class Flow<S: Equatable>: Element<S> {
	private var elements: [Element<S>]

	private var parentView: NSView?

	private let direction: Direction

	public init(_ direction: Direction,_ elements: [Element<S>]) {
		self.direction = direction
		self.elements = elements
	}

	public convenience init(_ direction: Direction, _ elements: Element<S>...) {
		self.init(direction, elements)
	}

	// MARK: Element

	public override func applyDiff(other: Element<S>) {
		let otherFlow = other as Flow<S>
		for pair in Zip2(elements, otherFlow.elements) {
			if (pair.0.canDiff(pair.1)) {
				pair.0.applyDiff(pair.1)
			} else {
//				pair.0.derealize()
//				if let parentView = parentView {
//					pair.1.realize(self, parentView: hostView)
//				}
				println("Wep")
			}
		}

		layoutElements()
	}

	private func layoutElements() {
		if parentView == nil { return }

		var y: CGFloat = parentView!.frame.size.height
		for element in elements {
			if let v = element.getContentView() {
				y -= v.frame.size.height
				v.frame.origin.y = y
			}
		}
	}

	public override func realize(component: Component<S>, parentView: NSView) {
		self.parentView = parentView

		for element in elements {
			element.realize(component, parentView: parentView)
		}

		layoutElements()

		super.realize(component, parentView: parentView)
	}

	public override func derealize() {
		for element in elements {
			element.derealize()
		}
	}

	public override func getContentView() -> NSView? {
		return nil
	}
}
