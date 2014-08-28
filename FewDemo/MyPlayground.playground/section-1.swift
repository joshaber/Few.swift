// Playground - noun: a place where people can play

import Cocoa
import Few

var t = absolute(fillRect(NSColor.redColor()), CGSize(width: 200, height: 200))

var v = absolute(fillRect(NSColor.greenColor()), CGSize(width: 100, height: 100))

var s = Container([t, offset(v, 20, 20)])
s.frame = CGRect(origin: CGPointZero, size: CGSize(width: 200, height: 200))

v.pre()

t.pre()

s.pre()
