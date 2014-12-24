// Playground - noun: a place where people can play

import Cocoa
import Few

let rect = fillRect()
			.fillColor(NSColor.redColor())
			.width(100)
			.height(100)
rect.ql

let rr = fillRoundedRect(3)
		.fillColor(NSColor.greenColor())
		.width(25)
		.height(25)
		.center(rect)
rr.ql

let bg = fillRect()
		.fillColor(NSColor.grayColor())
		.width(200)
		.height(200)

let input1 = Input(initialText: nil, placeholder: "First name") { str in }
			.centerY(bg)
			.offsetX(16)

let input2 = Input(initialText: nil, placeholder: "Last name") { str in }
			.below(input1)
			.alignLeft(input1)

let label = Label(text: "Lol").below(input2).alignRight(input2)

let button = Button(title: "Click me!") {}
			.sizeToFit()
			.right(input1)
			.alignBottom(input1)

let container = Container([bg, rect, rr, input1, button, input2, label])
				.width(200)
				.height(200)
container.ql
