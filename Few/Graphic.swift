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
	private let draw: () -> ()

	init(frame: NSRect, draw: () -> ()) {
		self.draw = draw
		super.init(frame: frame)
	}

	required init(coder: NSCoder) {
		fatalError("DrawableView shouldn't be serialized.");
	}

	override func drawRect(rect: NSRect) {
		draw()
	}
}

public func rect<S>(size: CGSize, #color: NSColor) -> Element<S> {
	let path = NSBezierPath(rect: CGRect(origin: CGPointZero, size: size))
	return Graphic {
		color.set()
		path.fill()
	}
}

public class Graphic<S: Equatable>: Element<S> {
	private var view: DrawableView?

	private var draw: () -> ()

	public init(draw: () -> ()) {
		self.draw = draw
	}

	// MARK: Element

	public override func applyDiff(other: Element<S>) {
		let otherGraphic = other as Graphic
		draw = otherGraphic.draw
		view?.needsDisplay = true
	}

	public override func realize(component: Component<S>, parentView: NSView) {
		view = DrawableView(frame: CGRect(x: 0, y: 0, width: 100, height: 100), draw: callDrawFunc)

		super.realize(component, parentView: parentView)
	}

	private func callDrawFunc() {
		draw()
	}

	public override func getContentView() -> NSView? {
		return view
	}
}
