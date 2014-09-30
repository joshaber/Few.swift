//
//  Component.swift
//  Few
//
//  Created by Josh Abernathy on 8/1/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import AppKit

public class Component<S>: Element {
	/// The state on which the component depends.
	private var state: S

	private let render: S -> Element

	private var topElement: Element

	private var hostView: NSView?

	public init(render: S -> Element, initialState: S) {
		self.render = render
		self.state = initialState
		self.topElement = render(initialState)
	}
	
	// MARK: Lifecycle
	
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
		
		componentDidUpdate()
	}
	
	/// Called when the component will be realized.
	public func componentWillRealize() {}
	
	/// Called when the component has been realized.
	public func componentDidRealize() {}
	
	/// Called when the component is about to be derealized.
	public func componentWillDerealize() {}
	
	/// Called when the component has been derealized.
	public func componentDidDerealize() {}
	
	/// Called after the component has been updated and diff applied.
	public func componentDidUpdate() {}
	
	/// Called when the state has changed but before the component is 
	/// re-rendered. This gives the component the chance to decide whether it 
	/// *should* based on the new state.
	///
	/// The default implementation always returns true.
	public func shouldUpdate(previousState: S, newState: S) -> Bool {
		return true
	}
	
	// MARK: -

	/// Add the component to the given view.
	public func addToView(view: NSView) {
		assert(hostView == nil, "\(self) has already been added to a view. Remove it before adding it to a new view.")
		
		componentWillRealize()
		
		hostView = view
		topElement.realize(self, parentView: view)
		
		componentDidRealize()
	}
	
	/// Remove the component from its host view.
	public func remove() {
		componentWillDerealize()
		
		topElement.derealize()
		hostView = nil
		
		componentDidDerealize()
	}
	
	/// Update the state using the given function.
	public func updateState(fn: S -> S) -> S {
		precondition(NSThread.isMainThread(), "Component.updateState called on a background thread. Donut do that!")

		let oldState = state
		state = fn(oldState)
		
		if shouldUpdate(oldState, newState: state) {
			update()
		}
		
		return state
	}
	
	// MARK: Element
	
	public override func canDiff(other: Element) -> Bool {
		if !super.canDiff(other) { return false }
		
		let otherComponent = other as Component
		return self === otherComponent
	}
	
	public override func applyDiff(other: Element) {
		// This is pretty meaningless since we check for pointer equality in
		// canDiff.
	}
	
	public override func realize(parent: Element, parentView: NSView) {
		addToView(parentView)
	}
	
	public override func derealize() {
		getContentView()?.removeFromSuperview()
	}
	
	public override func getContentView() -> NSView? {
		return topElement.getContentView()
	}
}
