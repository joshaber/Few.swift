//
//  Component.swift
//  Few
//
//  Created by Josh Abernathy on 8/1/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import AppKit

public class Component<S, T: Setable where T.ValueType == S>: Element<S, T> {
	internal var state: Observable<S>

	private let render: S -> Element<S, T>

	private var topElement: Element<S, T>

	private var hostView: NSView?

	public init(render: S -> Element<S, T>, initialState: S) {
		self.render = render
		self.state = Observable(initialValue: initialState)
		self.topElement = render(initialState)
		super.init()

		self.state.addObserver {[unowned self] _ in
			self.redraw()
		}
	}

	deinit {
		// TODO: Probably remove the observer?
	}

	private func redraw() {
		let otherElement = render(state.value)

		if topElement.canDiff(otherElement) {
			topElement.applyDiff(otherElement)
		} else {
			topElement.derealize()
			topElement = otherElement

			if let hostView = hostView {
				let s = state as T
				topElement.realize(hostView, setable: s)
			}
		}
	}

	public func addToView(view: NSView) {
		hostView = view
		let s = state as T
		topElement.realize(view, setable: s)
	}

	public override func canDiff(other: Element<S, T>) -> Bool {
		if other.dynamicType !== self.dynamicType {
			return false
		}

		let otherComponent = other as Component
		return topElement.canDiff(otherComponent.topElement)
	}

	public override func applyDiff(other: Element<S, T>) {
		let otherComponent = other as Component
		topElement.applyDiff(otherComponent.topElement)
	}

	public override func realize(parentView: NSView, setable: T) {
		addToView(parentView)
	}

	public override func getContentView() -> NSView? {
		return topElement.getContentView()
	}
}
