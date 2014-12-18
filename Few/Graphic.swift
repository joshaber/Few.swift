//
//  Graphic.swift
//  Few
//
//  Created by Josh Abernathy on 12/16/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Cocoa

private class GraphicView: NSView {
	private var draw: (CGRect -> ())?

	private override func drawRect(dirtyRect: NSRect) {
		draw?(bounds)
	}
}

public class Graphic: Element {
	private let draw: CGRect -> ()

	public init(draw: CGRect -> ()) {
		self.draw = draw
		super.init()
	}

	public required init(copy: Element, frame: CGRect, hidden: Bool, key: String?) {
		let graphic = copy as Graphic
		draw = graphic.draw
		super.init(copy: copy, frame: frame, hidden: hidden, key: key)
	}

	// MARK: Element

	public override func applyDiff(view: ViewType, other: Element) {
		let graphicView = view as GraphicView
		graphicView.draw = draw
		graphicView.needsDisplay = true

		super.applyDiff(view, other: other)
	}

	public override func realize() -> ViewType? {
		let view = GraphicView(frame: frame)
		view.draw = draw
		return view
	}
}

public func fillRect(color: ColorType) -> Graphic {
	return Graphic { b in
		color.set()
		NSRectFillUsingOperation(b, .CompositeSourceOver)
	}
}

public func fillRoundedRect(radius: CGFloat, color: ColorType) -> Graphic {
	return Graphic { b in
		let path = NSBezierPath(roundedRect: b, xRadius: radius, yRadius: radius)
		color.set()
		path.fill()
	}
}
