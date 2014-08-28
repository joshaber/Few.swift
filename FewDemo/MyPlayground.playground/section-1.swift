// Playground - noun: a place where people can play

import Cocoa
import Few

var t = fillRect(NSColor.redColor())
	 |> absolute(CGSize(width: 200, height: 200))

var v = fillRect(NSColor.greenColor())
	 |> absolute(CGSize(width: 100, height: 100))
	 |> offset(20, 40)

var s = Container([t, v])
s.frame = CGRect(origin: CGPointZero, size: CGSize(width: 200, height: 200))

v.pre()

t.pre()

s.pre()
