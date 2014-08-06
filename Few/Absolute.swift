//
//  Absolute.swift
//  Few
//
//  Created by Josh Abernathy on 8/5/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import AppKit

public class Absolute<S: Equatable>: Element<S> {
	private var element: Element<S>

	private var frame: CGRect

	public init(element: Element<S>, frame: CGRect) {
		self.element = element
		self.frame = frame
	}

	// MARK: Element

	public override func canDiff(other: Element<S>) -> Bool {
		if !super.canDiff(other) { return false }

		let otherAbsolute = other as Absolute<S>
		return element.canDiff(otherAbsolute.element)
	}

	public override func applyDiff(other: Element<S>) {
		let otherAbsolute = other as Absolute<S>
		element.applyDiff(otherAbsolute.element)

		if let v = getContentView() {
			v.frame = frame
		}
	}

	public override func realize(component: Component<S>, parentView: NSView) {
		element.realize(component, parentView: parentView)
	}

	public override func derealize() {
		element.derealize()
	}

	public override func getContentView() -> NSView? {
		return nil
	}
}
