//
//  WrappedView.swift
//  Few
//
//  Created by Josh Abernathy on 10/30/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation

public class WrappedView: Element {
	let view: ViewType
	let element: Element

	public init(view: ViewType, element: Element) {
		self.view = view
		self.element = element
		super.init()
		self.sizingBehavior = .None
	}

	// MARK: Element

	public override func realize() -> ViewType? {
		return view
	}

	public override func derealize() {
		element.derealize()
	}

	public override func canDiff(other: Element) -> Bool {
		if !super.canDiff(other) { return false }

		let otherView = other as WrappedView
		return element.canDiff(otherView.element)
	}

	public override func applyDiff(view: ViewType, other: Element) {
		let otherView = other as WrappedView
		element.applyDiff(view, other: otherView.element)
	}
}
