//
//  CustomButton.swift
//  Few
//
//  Created by Josh Abernathy on 2/28/15.
//  Copyright (c) 2015 Josh Abernathy. All rights reserved.
//

import Cocoa
import Few

typealias CustomButton = CustomButton_<Bool>
class CustomButton_<LOL>: Component<Bool> {
	init() {
		super.init(initialState: false, render: CustomButton_.render)
	}

	class func render(component: Component<Bool>, active: Bool) -> Element {
		let color = (active ? NSColor.greenColor() : NSColor.blackColor())
		return View(
			borderColor: color,
			cornerRadius: 4,
			borderWidth: 1,
			mouseDown: { _ in component.updateState(const(true)) },
			mouseUp: { _ in component.updateState(const(false)) })
			.children([
				Label(text: "Click me!")
			])
	}
}
