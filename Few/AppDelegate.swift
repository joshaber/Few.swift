//
//  AppDelegate.swift
//  Few
//
//  Created by Josh Abernathy on 7/22/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Cocoa

func renderBg(tick: Float) -> Element<Float> {
	let R = (128 + sin((tick * 3 + 0) * 1.3) * 128) / 255
	let G = (128 + sin((tick * 3 + 1) * 1.3) * 128) / 255
	let B = (128 + sin((tick * 3 + 2) * 1.3) * 128) / 255
	let color = NSColor(calibratedRed: CGFloat(R), green: CGFloat(G), blue: CGFloat(B), alpha: 1)
	return absolute(fillRect(color), CGSize(width: 1000, height: 1000))
}

private let bgComponent = Component(render: renderBg, initialState: 0)

func render(state: GameState) -> Element<GameState> {
	return bgComponent + renderGame(state)
}

class AppDelegate: NSObject, NSApplicationDelegate {
	@IBOutlet weak var window: NSWindow!

	private let component = Component(render: render, initialState: GameState(winningScore: 5))

	func applicationDidFinishLaunching(notification: NSNotification?) {
		let contentView = window.contentView as NSView
		component.addToView(contentView)

		every(0.01) {
			bgComponent.state += 0.001
		}
	}
}
