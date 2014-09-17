//
//  AppDelegate.swift
//  Few
//
//  Created by Josh Abernathy on 7/22/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Cocoa
import Few

func renderBg(tick: Float) -> Element {
	let low: Float = 200
	let R = (low + sin((tick * 3 + 0) * 1.3) * 128) / 255
	let G = (low + sin((tick * 3 + 1) * 1.3) * 128) / 255
	let B = (low + sin((tick * 3 + 2) * 1.3) * 128) / 255
	let color = NSColor(calibratedRed: CGFloat(R), green: CGFloat(G), blue: CGFloat(B), alpha: 1)
	return sized(fillRect(color), CGSize(width: 1000, height: 1000))
}

var timer: NSTimer?
let bgComponent = Component(
	render: renderBg,
	initialState: 0,
	didRealize: { c in
		timer = every(0.01) {
			c.state += 0.01
		}
	},
	willDerealize: constF(void(timer?.invalidate())))

class AppDelegate: NSObject, NSApplicationDelegate {
	@IBOutlet weak var window: NSWindow!
	
	private let appComponent = Component(render: const(bgComponent + gameComponent), initialState: ())
	
	func applicationDidFinishLaunching(notification: NSNotification?) {
		let contentView = window.contentView as NSView
		appComponent.addToView(contentView)
	}
}
