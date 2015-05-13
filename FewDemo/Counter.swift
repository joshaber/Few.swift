//
//  Counter.swift
//  Few
//
//  Created by Josh Abernathy on 3/28/15.
//  Copyright (c) 2015 Josh Abernathy. All rights reserved.
//

import AppKit
import Few

typealias Counter = Counter_<Int>
class Counter_<LOL>: Component<Int> {
	init() {
		super.init(initialState: 0)
	}

	override func render() -> Element {
		let count = state
		return View(
			backgroundColor: NSColor.blueColor())
			// The view itself should be centered.
			.justification(.Center)
			// The children should be centered in the view.
			.childAlignment(.Center)
			// Layout children in a column.
			.direction(.Column)
			.children([
				Label("You've clicked \(count) times!"),
				Button(title: "Click me!", action: {
						self.updateState { $0 + 1 }
					})
					.margin(Edges(uniform: 10))
					.width(100),
				])
	}
}
