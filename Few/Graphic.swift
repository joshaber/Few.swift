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
	private let draw: CGRect -> ()

	public init(draw: CGRect -> ()) {
		self.draw = draw
	}

	// MARK: Element

	public override func applyDiff(view: ViewType, other: Element) {
		let otherGraphic = other as Graphic
		let drawableView = view as DrawableView

		drawableView.draw = draw
		drawableView.needsDisplay = true

		super.applyDiff(view, other: other)
	}

	public override func realize() -> ViewType? {
		return DrawableView(frame: frame, draw: callDrawFunc)
	}

	private func callDrawFunc(rect: CGRect) {
		draw(rect)
	}
}
