//
//  Flow.swift
//  Few
//
//  Created by Josh Abernathy on 8/5/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import AppKit

public class Flow<S: Equatable>: Element<S> {
	private var elements: [Element<S>]

	private var parentView: NSView?

	public init(_ elements: [Element<S>]) {
		self.elements = elements
	}

	public convenience init(_ elements: Element<S>...) {
		self.init(elements)
	}

	// MARK: Element

	public override func applyDiff(other: Element<S>) {
		let otherFlow = other as Flow<S>
		var y: CGFloat = parentView?.frame.size.height ?? 0
		for pair in Zip2(elements, otherFlow.elements) {
			if (pair.0.canDiff(pair.1)) {
				pair.0.applyDiff(pair.1)

				if let v = pair.0.getContentView() {
					y -= v.frame.size.height
					v.frame.origin.y = y
				}
			} else {
				println("Wep")
			}
		}
	}

	public override func realize(component: Component<S>, parentView: NSView) {
		self.parentView = parentView

		for element in elements {
			element.realize(component, parentView: parentView)
		}

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

extension Flow: ArrayLiteralConvertible {
	public class func convertFromArrayLiteral(elements: Element<S>...) -> Flow<S> {
		return Flow(elements)
	}
}
