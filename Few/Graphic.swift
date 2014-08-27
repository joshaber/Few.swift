//
//  Graphic.swift
//  Few
//
//  Created by Josh Abernathy on 8/6/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import AppKit

private class DrawableView: NSView {
	private let draw: CGRect -> ()

	init(frame: NSRect, draw: CGRect -> ()) {
		self.draw = draw
		super.init(frame: frame)
	}

	required init(coder: NSCoder) {
		fatalError("DrawableView shouldn't be serialized.");
	}

	override func drawRect(rect: NSRect) {
		draw(rect)
	}
}

public func fillRect(color: NSColor) -> Graphic {
	return Graphic { rect in
		color.set()
		NSRectFillUsingOperation(rect, .CompositeSourceOver)
	}
}

public func strokeRect(color: NSColor, width: CGFloat) -> Graphic {
	return Graphic { rect in
		color.set()
		NSFrameRectWithWidthUsingOperation(rect, width, .CompositeSourceOver)
	}
}

public func image(image: NSImage) -> Graphic {
	return Graphic { rect in
		image.drawInRect(rect, fromRect: CGRectZero, operation: .CompositeSourceOver, fraction: 1)
	}
}

public class Graphic: Element {
	private var view: DrawableView?

	private var draw: CGRect -> ()

	public init(draw: CGRect -> ()) {
		self.draw = draw
	}

	// MARK: Element

	public override func applyDiff(other: Element) {
		let otherGraphic = other as Graphic
		draw = otherGraphic.draw
		view?.needsDisplay = true
	}

	public override func realize<S>(component: Component<S>, parentView: NSView) {
		view = DrawableView(frame: frame, draw: callDrawFunc)

		super.realize(component, parentView: parentView)
	}

	private func callDrawFunc(rect: CGRect) {
		draw(rect)
	}

	public override func getContentView() -> NSView? {
		return view
	}
}
