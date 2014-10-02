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
	private var draw: CGRect -> ()

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

public func fillRect() -> Graphic {
	return Graphic { rect in
		NSRectFillUsingOperation(rect, .CompositeSourceOver)
	}
}

public func strokeRect(color: NSColor, width: CGFloat) -> Graphic {
	return Graphic { rect in
		color.set()
		NSFrameRectWithWidthUsingOperation(rect, width, .CompositeSourceOver)
	}
}

public func fillRect(color: NSColor, cornerRadius: CGFloat) -> Graphic {
	return Graphic { rect in
		color.set()
		let path = NSBezierPath(roundedRect: rect, xRadius: cornerRadius, yRadius: cornerRadius)
		path.fill()
	}
}

public func fillPath(path: NSBezierPath) -> Graphic {
	return Graphic { rect in
		path.fill()
	}
}

public func strokePath(path: NSBezierPath) -> Graphic {
	return Graphic { rect in
		path.stroke()
	}
}

public func image(image: NSImage) -> Graphic {
	return Graphic { rect in
		image.drawInRect(rect, fromRect: CGRectZero, operation: .CompositeSourceOver, fraction: 1)
	}
}

public func color(color: NSColor)(graphic: Graphic) -> Graphic {
	return Graphic { rect in
		color.set()
		graphic.draw(rect)
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
		view = otherGraphic.view

		view?.draw = draw
		view?.needsDisplay = true

		super.applyDiff(other)
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
