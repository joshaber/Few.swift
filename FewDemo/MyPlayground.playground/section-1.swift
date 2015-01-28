// Playground - noun: a place where people can play

import Cocoa
import Few
import XCPlayground

func container1() -> Element {
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
		.centerY(input1)

	return bg + rect + rr + input1 + button + input2 + label
}

func container2() -> Element {
	let label = Label(text: "100").y(180)

	let add = Button(title: "Add") {}
             .right(label)
             .centerY(label)

	let like = Label(text: "I donut like this.")
              .below(add)
              .offsetY(-4)

	let toggle = Button(title: "Toggle") {}
                .below(like)
                .sizeToFit()
                .offsetY(-4)

	let logout = Button(title: "Log Out") {}
                .below(toggle)
                .sizeToFit()

	return (label + add + like + toggle + logout)
          .width(200)
          .height(200)
}

container1().ql
XCPShowView("c2", container2().ql)

let label = Label(text: "Hi")
let input = Input(initialText: nil, placeholder: "Your name") { _ in }.right(label)
(label + input).ql
