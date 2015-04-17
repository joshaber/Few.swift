// Playground - noun: a place where people can play

import Cocoa
import Few
import XCPlayground

let view = View(backgroundColor: NSColor.redColor())
	.direction(.Column)
	.justification(.FlexEnd)
	.children([
		Label("Bleh").size(100, 23),
		Label("World").size(100, 23),
		Button(title: "Yoo").margin(Edges(uniform: 4))
	])
let component = Component(initialState: ()) { _, _ in view }

let host = NSView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
component.addToView(host)
host
