//
//  View.swift
//  Few
//
//  Created by Josh Abernathy on 2/6/15.
//  Copyright (c) 2015 Josh Abernathy. All rights reserved.
//

import Foundation
import AppKit

private class FewView: NSView {
	private var backgroundColor: NSColor? {
		didSet {
			needsDisplay = true
		}
	}

	private var borderColor: NSColor? {
		didSet {
			needsDisplay = true
		}
	}

	private var borderWidth: CGFloat = 0 {
		didSet {
			needsDisplay = true
		}
	}

	private var cornerRadius: CGFloat = 0 {
		didSet {
			needsDisplay = true
		}
	}

	var mouseDown: (() -> ())?
	var mouseUp: (() -> ())?
	var mouseExited: (() -> ())?
	var keyDown: (NSEvent -> Bool)?
	var keyUp: (NSEvent -> Bool)?

	private var tracking = false

	private override func drawRect(dirtyRect: NSRect) {
		var path: NSBezierPath!
		if cornerRadius.isZero {
			path = NSBezierPath(rect: bounds)
		} else {
			var pathBounds = bounds
			if borderWidth <= 1 {
				pathBounds = CGRectInset(bounds, 0.5, 0.5)
			}
			path = NSBezierPath(roundedRect: pathBounds, xRadius: cornerRadius, yRadius: cornerRadius)
		}

		if let color = backgroundColor {
			color.set()
			path.fill()
		}

		if let color = borderColor {
			if borderWidth > 0 {
				color.set()
				path.lineWidth = borderWidth
				path.stroke()
			}
		}
	}

	private override func mouseDown(event: NSEvent) {
		super.mouseDown(event)

		propagateMouseDown()
	}

	private override func mouseUp(event: NSEvent) {
		super.mouseUp(event)

		if tracking {
			mouseUp?()

			tracking = false
		}
	}

	private final func propagateMouseDown() {
		tracking = true

		mouseDown?()
	}

	private override func keyUp(event: NSEvent) {
		if let keyUp = keyUp {
			if !keyUp(event) {
				super.keyUp(event)
			}
		} else {
			super.keyUp(event)
		}
	}

	private override func keyDown(event: NSEvent) {
		if let keyDown = keyDown {
			if !keyDown(event) {
				super.keyDown(event)
			}
		} else {
			super.keyDown(event)
		}
	}

	private override func mouseDragged(event: NSEvent) {
		super.mouseDragged(event)

		let loc = convertPoint(event.locationInWindow, fromView: nil)
		let inView = NSMouseInRect(loc, bounds, flipped)
		// If the drag exited our bounds then treat it as a mouse up.
		if tracking && !inView {
			mouseExited?()
			tracking = false
		} else if !tracking && inView {
			propagateMouseDown()
		}
	}

	@objc var backgroundStyle: NSBackgroundStyle = .Light {
		didSet {
			for view in subviews {
				if let control = view as? NSControl {
					if let cell = control.cell() as? NSCell {
						cell.backgroundStyle = backgroundStyle
					}
				} else if let fewView = view as? FewView {
					fewView.backgroundStyle = backgroundStyle
				}
			}
		}
	}
}

private let doNothing: View -> () = { _ in }
private let doNothingKeyEvent: (View, NSEvent) -> Bool = { _, _ in false }

public class View: Element {
	public var backgroundColor: NSColor?
	public var borderColor: NSColor?
	public var borderWidth: CGFloat
	public var cornerRadius: CGFloat
	public var mouseDown: View -> ()
	public var mouseUp: View -> ()
	public var mouseExited: View -> ()
	public var keyDown: (View, NSEvent) -> Bool
	public var keyUp: (View, NSEvent) -> Bool

	public init(backgroundColor: NSColor? = nil, borderColor: NSColor? = nil, borderWidth: CGFloat = 0, cornerRadius: CGFloat = 0, mouseDown: View -> () = doNothing, mouseUp: View -> () = doNothing, mouseExited: View -> () = doNothing, keyDown: (View, NSEvent) -> Bool = doNothingKeyEvent, keyUp: (View, NSEvent) -> Bool = doNothingKeyEvent) {
		self.backgroundColor = backgroundColor
		self.borderColor = borderColor
		self.borderWidth = borderWidth
		self.cornerRadius = cornerRadius
		self.mouseDown = mouseDown
		self.mouseUp = mouseUp
		self.mouseExited = mouseExited
		self.keyDown = keyDown
		self.keyUp = keyUp
	}

	// MARK: Element

	public override func applyDiff(old: Element, realizedSelf: RealizedElement?) {
		super.applyDiff(old, realizedSelf: realizedSelf)

		if let backgroundView = realizedSelf?.view as? FewView {
			if backgroundColor !== backgroundView.backgroundColor {
				backgroundView.backgroundColor = backgroundColor
			}

			if borderColor !== backgroundView.borderColor {
				backgroundView.borderColor = borderColor
			}

			if fabs(borderWidth - backgroundView.borderWidth) > CGFloat(DBL_EPSILON) {
				backgroundView.borderWidth = borderWidth
			}

			if fabs(cornerRadius - backgroundView.cornerRadius) > CGFloat(DBL_EPSILON) {
				backgroundView.cornerRadius = cornerRadius
			}

			configEventHandlers(backgroundView)
		}
	}

	public override func createView() -> ViewType {
		let view = FewView(frame: CGRectZero)
		view.backgroundColor = backgroundColor
		view.borderColor = borderColor
		view.borderWidth = borderWidth
		view.cornerRadius = cornerRadius
		view.alphaValue = alpha
		view.hidden = hidden
		configEventHandlers(view)
		return view
	}

	private final func configEventHandlers(view: FewView) {
		view.mouseDown = { [weak self] in
			if let strongSelf = self {
				strongSelf.mouseDown(strongSelf)
			}
		}

		view.mouseUp = { [weak self] in
			if let strongSelf = self {
				strongSelf.mouseUp(strongSelf)
			}
		}

		view.mouseExited = { [weak self] in
			if let strongSelf = self {
				strongSelf.mouseExited(strongSelf)
			}
		}

		view.keyUp = { [weak self] event in
			if let strongSelf = self {
				return strongSelf.keyUp(strongSelf, event)
			} else {
				return false
			}
		}

		view.keyDown = { [weak self] event in
			if let strongSelf = self {
				return strongSelf.keyDown(strongSelf, event)
			} else {
				return false
			}
		}
	}
}
