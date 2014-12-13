//
//  AppDelegate.swift
//  Few
//
//  Created by Josh Abernathy on 7/22/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Cocoa
import Few

class AppDelegate: NSObject, NSApplicationDelegate {
	@IBOutlet weak var window: NSWindow!

	private let appComponent = DemoComponent2<DemoState2>()

	func applicationDidFinishLaunching(notification: NSNotification?) {
		let contentView = window.contentView as NSView
		var red = newElement(10, 10, .Space)
		red.properties.color = NSColor.redColor()
		let green = newElement(10, 10, .Space)
		let blue = newElement(10, 10, .Space)
		let elements = flow(.Right)(elements: [red, green, blue])
		contentView.addSubview(render(elements))
	}
}
