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
	let b = View(type: NSButton.self) { b in b.title = "HELLO YES THIS IS DOG" } |> frame(CGRect(x: 0, y: 0, width: 160, height: 23))
	return (fillRect(color) |> frame(CGRect(x: 0, y: 0, width: 1000, height: 1000))) + b
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
