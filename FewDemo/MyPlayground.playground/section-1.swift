// Playground - noun: a place where people can play

import Cocoa
import Few

var t = fillRect(NSColor.redColor())
	|> frame(CGRect(x: 0, y: 0, width: 200, height: 200))

var v = fillRect()
	|> color(NSColor.redColor())
	|> frame(CGRect(x: 20, y: 40, width: 100, height: 100))

v.pre()

t.pre()

var rr = fillRect(NSColor.blueColor(), 5)
	|> frame(CGRect(x: 50, y: 0, width: 100, height: 100))
rr.pre()

var container1 = Container([t, v, rr])
container1.frame = CGRect(origin: CGPointZero, size: CGSize(width: 200, height: 200))

container1.pre()
