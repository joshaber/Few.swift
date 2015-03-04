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
	var title: String
	var action: () -> ()

	init(title: String, action: () -> () = { }) {
		self.title = title
		self.action = action
		super.init(initialState: false, render: CustomButton_.render)
	}

	class func render(c: Component<Bool>, active: Bool) -> Element {
		let component = c as! CustomButton
		let color = (active ? NSColor.greenColor() : NSColor.blackColor())
		return View(
			borderColor: color,
			cornerRadius: 4,
			backgroundColor: .whiteColor(),
			borderWidth: 1,
			mouseDown: { _ in component.updateState(const(true)) },
			mouseUp: { _ in
				component.updateState(const(false))
				component.action()
			},
			mouseExited: { _ in component.updateState(const(false)) })
			.children([
				Label(text: component.title, textColor: color).margin(Edges(uniform: 4))
			])
	}
}
