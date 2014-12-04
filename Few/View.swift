//
//  View.swift
//  Few
//
//  Created by Josh Abernathy on 10/30/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation

public class View: Element {
	private let view: ViewType
	private let element: Element

	public init(view: ViewType, element: Element) {
		self.view = view
		self.element = element
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

		let otherView = other as View
		return element.canDiff(otherView.element)
	}

	public override func applyDiff(view: ViewType, other: Element) {
		let otherView = other as View
		element.applyDiff(view, other: otherView.element)
	}
}
