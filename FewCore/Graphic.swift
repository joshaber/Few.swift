//
//  Graphic.swift
//  Few
//
//  Created by Josh Abernathy on 12/16/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import CoreGraphics

private class GraphicView: ViewType {
	private var draw: (CGRect -> ())?

	private override func drawRect(dirtyRect: CGRect) {
		draw?(bounds)
	}
}

private let DefaultFrame = CGRect(x: 0, y: 0, width: 100, height: 100)

public class Graphic: Element {
	private let draw: CGRect -> ()

	public init(draw: CGRect -> ()) {
		self.draw = draw
		super.init(frame: DefaultFrame)
	}

	public required init(copy: Element, frame: CGRect, hidden: Bool, alpha: CGFloat, key: String?) {
		let graphic = copy as Graphic
		draw = graphic.draw
		super.init(copy: copy, frame: frame, hidden: hidden, alpha: alpha, key: key)
	}

	public required init(copy: Element, frame: CGRect, hidden: Bool, alpha: CGFloat, key: String?, draw: CGRect -> ()) {
		self.draw = draw
		super.init(copy: copy, frame: frame, hidden: hidden, alpha: alpha, key: key)
	}

	// MARK: Element

	public override func applyDiff(view: ViewType, other: Element) {
		let graphicView = view as GraphicView
		graphicView.draw = draw
		markNeedsDisplay(graphicView)

		super.applyDiff(view, other: other)
	}

	public override func realize() -> ViewType? {
		let view = GraphicView(frame: frame)
		view.draw = draw
		return view
	}
}

extension Graphic {
	final public func drawFn(fn: CGRect -> ()) -> Self {
		return self.dynamicType(copy: self, frame: frame, hidden: hidden, alpha: alpha, key: key, draw: fn)
	}

	final public func fillColor(c: ColorType) -> Graphic {
		return drawFn { b in
			c.setFill()
			self.draw(b)
		}
	}

	final public func strokeColor(c: ColorType) -> Graphic {
		return drawFn { b in
			c.setStroke()
			self.draw(b)
		}
	}

	final public func color(c: ColorType) -> Graphic {
		return drawFn { b in
			c.set()
			self.draw(b)
		}
	}
}

public func fillRect() -> Graphic {
	return Graphic { b in
		let context = currentCGContext()
		CGContextFillRect(context, b)
	}
}

public func strokeRect(width: CGFloat) -> Graphic {
	return Graphic { b in
		let context = currentCGContext()
		CGContextStrokeRectWithWidth(context, b, width)
	}
}

public func fillRoundedRect(radius: CGFloat) -> Graphic {
	return Graphic { b in
		let path = pathForRoundedRect(b, radius)
		path.fill()
	}
}

public func strokeRoundedRect(radius: CGFloat) -> Graphic {
	return Graphic { b in
		let path = pathForRoundedRect(b, radius)
		path.stroke()
	}
}
