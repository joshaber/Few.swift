// Playground - noun: a place where people can play

import Cocoa
import Few

var t = fillRect(NSColor.redColor())
	 |> sized(CGSize(width: 200, height: 200))

var v = fillRect()
	 |> color(NSColor.redColor())
	 |> sized(CGSize(width: 100, height: 100))
	 |> offset(20, 40)

v.pre()

t.pre()

var rr = fillRect(NSColor.blueColor(), 5)
	  |> sized(CGSize(width: 100, height: 100))
	  |> offset(50, 0)
rr.pre()

var container1 = Container([t, v, rr])
container1.frame = CGRect(origin: CGPointZero, size: CGSize(width: 200, height: 200))

container1.pre()
