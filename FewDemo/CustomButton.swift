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
		super.init(initialState: false)
	}

	override func render() -> Element {
		let active = state
		let color = (active ? NSColor.greenColor() : NSColor.blackColor())
		return View(
			borderColor: color,
			cornerRadius: 4,
			backgroundColor: .whiteColor(),
			borderWidth: 1,
			mouseDown: { _ in self.updateState(const(true)) },
			mouseUp: { _ in
				self.updateState(const(false))
				self.action()
			},
			mouseExited: { _ in self.updateState(const(false)) })
			.children([
				Label(title, textColor: color).margin(Edges(uniform: 4))
			])
			.margin(margin)
			.padding(padding)
	}
}
