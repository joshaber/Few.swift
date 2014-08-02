//
//  Component.swift
//  Few
//
//  Created by Josh Abernathy on 8/1/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import AppKit

public class Component<S: Equatable> {
	public var state: S {
	didSet {
		if oldValue != state {
			redraw()
		}
	}
	}

	private let render: S -> Element<S>

	private var topElement: Element<S>

	private var hostView: NSView?

	public init(render: S -> Element<S>, initialState: S) {
		self.render = render
		self.state = initialState
		self.topElement = render(initialState)
	}

	private func redraw() {
		let otherElement = render(state)

		if topElement.canDiff(otherElement) {
			topElement.applyDiff(otherElement)
		} else {
			topElement.derealize()
			topElement = otherElement

			if let hostView = hostView {
				topElement.realize(hostView, component: self)
			}
		}
	}

	public func addToView(view: NSView) {
		hostView = view
		topElement.realize(view, component: self)
	}
}
