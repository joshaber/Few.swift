// Playground - noun: a place where people can play

import Cocoa
import Few

let rect = fillRect(NSColor.redColor())
			.width(100)
			.height(100)
rect.ql

let rr = fillRoundedRect(3, NSColor.greenColor())
		.width(25)
		.height(25)
		.center(rect)
rr.ql

let bg = fillRect(NSColor.blackColor())
		.width(200)
		.height(200)

let input = Input(text: "Hi") { str in }
			.y(50)
			.above(rect)

let button = Button(title: "Click me!") {}
			.width(100)
			.right(input)
			.bottom(input)

let container = Container([bg, rect, rr, input, button])
				.width(200)
				.height(200)
container.ql
