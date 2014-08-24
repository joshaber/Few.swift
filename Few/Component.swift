//
//  Component.swift
//  Few
//
//  Created by Josh Abernathy on 8/1/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import AppKit

public class Component<S>: Element<S> {
	/// The state on which the component depends.
	public var state: S {
		didSet {
			if shouldUpdate(oldValue, newState: state) {
				update()
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

	private func update() {
		let otherElement = render(state)

		// If we can diff then apply it. Otherwise we just swap out the entire
		// hierarchy.
		if topElement.canDiff(otherElement) {
			topElement.applyDiff(otherElement)
		} else {
			topElement.derealize()
			topElement = otherElement

			if let hostView = hostView {
				topElement.realize(self, parentView: hostView)
			}
		}
	}
	
	/// Called when the state has changed but before the component is 
	/// re-rendered. This gives the component the chance to decide whether it 
	/// *should* based on the new state.
	///
	/// The default implementation always returns true.
	public func shouldUpdate(previousState: S, newState: S) -> Bool {
		return true
	}

	/// Add the component to the given view.
	public func addToView(view: NSView) {
		hostView = view
		topElement.realize(self, parentView: view)
	}

	// MARK: Element

	public override func canDiff(other: Element<S>) -> Bool {
		if other.dynamicType !== self.dynamicType {
			return false
		}

		let otherComponent = other as Component
		return topElement.canDiff(otherComponent.topElement)
	}

	public override func applyDiff(other: Element<S>) {
		let otherComponent = other as Component
		topElement.applyDiff(otherComponent.topElement)
	}

	public override func realize(component: Component<S>, parentView: NSView) {
		addToView(parentView)
	}

	public override func getContentView() -> NSView? {
		return topElement.getContentView()
	}
}
