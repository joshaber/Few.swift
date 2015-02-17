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

	private override func drawRect(dirtyRect: NSRect) {
		let path: NSBezierPath
		if cornerRadius.isZero {
			path = NSBezierPath(rect: bounds)
		} else {
			path = NSBezierPath(roundedRect: bounds, xRadius: cornerRadius, yRadius: cornerRadius)
		}

		if let color = backgroundColor {
			color.set()
			path.fill()
		}

		if let color = borderColor {
			color.set()
			path.lineWidth = borderWidth
			path.stroke()
		}
	}

	@objc override var opaque: Bool {
		return backgroundColor?.alphaComponent == 1
	}

	private override func mouseDown(event: NSEvent) {
		super.mouseDown(event)

		mouseDown?()
	}

	private override func mouseUp(event: NSEvent) {
		super.mouseUp(event)

		mouseUp?()
	}
}

public class View: Element {
	private static let doNothing: View -> () = { _ in }

	public var backgroundColor: NSColor?
	public var borderColor: NSColor?
	public var borderWidth: CGFloat
	public var cornerRadius: CGFloat
	public var mouseDown: View -> ()
	public var mouseUp: View -> ()

	public init(backgroundColor: NSColor? = nil, borderColor: NSColor? = nil, borderWidth: CGFloat = 0, cornerRadius: CGFloat = 0, mouseDown: View -> () = doNothing, mouseUp: View -> () = doNothing) {
		self.backgroundColor = backgroundColor
		self.borderColor = borderColor
		self.borderWidth = borderWidth
		self.cornerRadius = cornerRadius
		self.mouseDown = mouseDown
		self.mouseUp = mouseUp
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
		let view = FewView(frame: frame)
		view.backgroundColor = backgroundColor
		view.borderColor = borderColor
		view.borderWidth = borderWidth
		view.cornerRadius = cornerRadius
		configEventHandlers(view)
		return view
	}

	private func configEventHandlers(view: FewView) {
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
	}
}
