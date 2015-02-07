//
//  View.swift
//  Few
//
//  Created by Josh Abernathy on 2/6/15.
//  Copyright (c) 2015 Josh Abernathy. All rights reserved.
//

import Foundation
import AppKit

private class BackgroundView: NSView {
	private var backgroundColor: NSColor = .clearColor() {
		didSet {
			needsDisplay = true
		}
	}

	private override func drawRect(dirtyRect: NSRect) {
		backgroundColor.set()
		NSRectFillUsingOperation(bounds, .CompositeSourceOver)
	}

	@objc override var opaque: Bool {
		return backgroundColor.alphaComponent == 1
	}
}

public class View: Element {
	public let backgroundColor: NSColor

	public init(backgroundColor: NSColor = .clearColor()) {
		self.backgroundColor = backgroundColor
	}

	// MARK: Element

	public override func applyDiff(old: Element) {
		super.applyDiff(old)

		let backgroundView = view as BackgroundView
		if backgroundColor !== backgroundView.backgroundColor {
			backgroundView.backgroundColor = backgroundColor
		}
	}

	public override func createView() -> ViewType {
		let view = BackgroundView(frame: frame)
		view.backgroundColor = backgroundColor
		return view
	}
}
