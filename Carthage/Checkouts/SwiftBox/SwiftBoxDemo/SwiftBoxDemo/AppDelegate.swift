//
//  AppDelegate.swift
//  SwiftBoxDemo
//
//  Created by Josh Abernathy on 2/1/15.
//  Copyright (c) 2015 Josh Abernathy. All rights reserved.
//

import Cocoa
import SwiftBox

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	@IBOutlet weak var window: NSWindow!

	func applicationDidFinishLaunching(notification: NSNotification) {
		let contentView = window.contentView as! NSView
		let parent = Node(size: contentView.frame.size,
                          direction: .Row,
                          childAlignment: .Center,
                          children: [
			Node(flex: 75,
                 margin: Edges(left: 10, right: 10),
                 size: CGSize(width: 0, height: 100)),
			Node(flex: 15,
                 margin: Edges(right: 10),
                 size: CGSize(width: 0, height: 50)),
			Node(flex: 10,
                 margin: Edges(right: 10),
                 size: CGSize(width: 0, height: 180)),
		])

		let layout = parent.layout()
		println(layout)

		layout.apply(contentView)
	}
}
