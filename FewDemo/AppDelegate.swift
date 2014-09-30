//
//  AppDelegate.swift
//  Few
//
//  Created by Josh Abernathy on 7/22/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Cocoa
import Few

func renderBackground(tick: Float) -> Element {
	let low: Float = 200
	let R = (low + sin((tick * 3 + 0) * 1.3) * 128) / 255
	let G = (low + sin((tick * 3 + 1) * 1.3) * 128) / 255
	let B = (low + sin((tick * 3 + 2) * 1.3) * 128) / 255
	let color = NSColor(calibratedRed: CGFloat(R), green: CGFloat(G), blue: CGFloat(B), alpha: 1)
	let button1 = View(type: NSButton.self) { b in b.title = "HELLO YES THIS IS DOG" }
			|> frame(CGRect(x: 0, y: 0, width: 160, height: 23))

	let button2 = Button(title: "Hello yes this is dog.", fn: const(0))
		|> frame(CGRect(x: 0, y: 200, width: 160, height: 23))

	let fn = { (str: String, s: Float) -> Float in
		return s
	}
	let input = Input(initialText: "Hello? Is it me you're looking for?", fn: fn) |> frame(CGRect(x: 200, y: 300, width: 100, height: 23))

	let fullFrame = CGRect(x: 0, y: 0, width: 1000, height: 1000)
	let background = fillRect(color) |> frame(fullFrame)
	return Container(background,
		             button1,
		             button2,
		             input)
			|> frame(fullFrame)
}

// This is to work around Swift's inability to have non-generic subclasses of a
// generic superclass.
typealias BackgroundComponent = BackgroundComponent_<Any>
class BackgroundComponent_<Bullshit>: Few.Component<Float> {
	var timer: NSTimer?
	
	init() {
		super.init(render: renderBackground, initialState: 0)
	}
	
	override func componentDidRealize() {
		timer = every(0.01) { [unowned self] in
			void(self.updateState { s in s + 0.01 })
		}
	}
	
	override func componentWillDerealize() {
		timer?.invalidate()
	}
}

let backgroundComponent = BackgroundComponent()

class AppDelegate: NSObject, NSApplicationDelegate {
	@IBOutlet weak var window: NSWindow!

	private let appComponent = Component(render: const(backgroundComponent), initialState: ())
	
	func applicationDidFinishLaunching(notification: NSNotification?) {
		let contentView = window.contentView as NSView
		backgroundComponent.addToView(contentView)
	}
}
