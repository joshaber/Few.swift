//
//  Component.swift
//  Few
//
//  Created by Josh Abernathy on 8/1/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import AppKit

/// Components are stateful elements and the bridge between Few and 
/// AppKit/UIKit.
///
/// By default whenever the component's state is changed, it re-renders itself 
/// by calling the `render` function passed in to its init. But subclasses can
/// optimize this by implementing `componentShouldUpdate`.
public class Component<S>: Element {
	/// The state on which the component depends.
	private var state: S

	private let render: S -> Element

	private var rootElement: Element

	private var hostView: ViewType?

	/// Initializes the component with a render function and its initial state.
	/// The render function takes the current state of the component and returns
	/// the element which represents that state.
	public init(render: S -> Element, initialState: S) {
		self.render = render
		self.state = initialState
		self.rootElement = render(initialState)
	}
	
	// MARK: Lifecycle
	
	private func update() {
		let newRoot = render(state)

		// If we can diff then apply it. Otherwise we just swap out the entire
		// hierarchy.
		if newRoot.canDiff(rootElement) {
			newRoot.applyDiff(rootElement)
		} else {
			rootElement.derealize()

			if let hostView = hostView {
				newRoot.realize(self, parentView: hostView)
			}
		}

		rootElement = newRoot
		
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
	public func componentShouldUpdate(previousState: S, newState: S) -> Bool {
		return true
	}
	
	// MARK: -

	/// Add the component to the given view.
	public func addToView(view: ViewType) {
		assert(hostView == nil, "\(self) has already been added to a view. Remove it before adding it to a new view.")
		
		componentWillRealize()
		
		hostView = view
		rootElement.realize(self, parentView: view)
		
		componentDidRealize()
	}
	
	/// Remove the component from its host view.
	public func remove() {
		componentWillDerealize()
		
		rootElement.derealize()
		hostView = nil
		
		componentDidDerealize()
	}
	
	/// Update the state using the given function.
	public func updateState(fn: S -> S) -> S {
		precondition(NSThread.isMainThread(), "Component.updateState called on a background thread. Donut do that!")

		let oldState = state
		state = fn(oldState)
		
		if componentShouldUpdate(oldState, newState: state) {
			update()
		}
		
		return state
	}
	
	// MARK: Element
	
	public override func canDiff(other: Element) -> Bool {
		if !super.canDiff(other) { return false }
		
		let otherComponent = other as Component
		return rootElement.canDiff(otherComponent.rootElement)
	}
	
	public override func applyDiff(other: Element) {
		if other === self { return }

		let otherComponent = other as Component
		hostView = otherComponent.hostView

		rootElement.applyDiff(otherComponent.rootElement)
	}
	
	public override func realize(parent: Element, parentView: ViewType) {
		addToView(parentView)
	}
	
	public override func derealize() {
		getContentView()?.removeFromSuperview()
	}
	
	public override func getContentView() -> ViewType? {
		return rootElement.getContentView()
	}
}
