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
/// Simple components can be created without subclassing. More complex
/// components will need to subclass it in order to add lifecycle events or 
/// customize its behavior further.
///
/// By default whenever the component's state is changed, it re-renders itself 
/// by calling the `render` function passed in to its init. But subclasses can
/// optimize this by implementing `componentShouldUpdate`.
public class Component<S>: Element {
	/// The state on which the component depends.
	private var state: S

	private var rootElement: Element?

	private var hostView: ViewType?

	private let renderFn: ((Component<S>, S) -> Element)?

	/// Initializes the component with its initial state. The render function 
	/// takes the current state of the component and returns the element which 
	/// represents that state.
	public init(initialState: S) {
		self.state = initialState
	}

	public init(render renderFn: (Component<S>, S) -> Element, initialState: S) {
		self.renderFn = renderFn
		self.state = initialState
	}

	// MARK: Lifecycle

	public func render(state: S) -> Element {
		if let renderFn = renderFn {
			return renderFn(self, state)
		} else {
			return Empty()
		}
	}

	private func update() {
		// We haven't been realized or added to a view yet, so no need to do 
		// anything.
		if rootElement == nil { return }

		let newRoot = render(state)

		// If we can diff then apply it. Otherwise we just swap out the entire
		// hierarchy.
		if newRoot.canDiff(rootElement!) {
			newRoot.applyDiff(rootElement!)
		} else {
			rootElement!.derealize()
			if let hostView = hostView {
				newRoot.realize(hostView)
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

		let rootElement = render(state)
		rootElement.frame = view.bounds
		rootElement.realize(view)

		self.rootElement = rootElement

		if let contentView = rootElement.getContentView() {
			contentView.autoresizingMask = NSAutoresizingMaskOptions.ViewWidthSizable | NSAutoresizingMaskOptions.ViewHeightSizable
		}
		
		componentDidRealize()
	}
	
	/// Remove the component from its host view.
	public func remove() {
		componentWillDerealize()
		
		rootElement?.derealize()
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

	/// Get the host view of the component.
	public func getHostView() -> ViewType? {
		return hostView
	}
	
	// MARK: Element
	
	public override func canDiff(other: Element) -> Bool {
		if !super.canDiff(other) { return false }
		
		let otherComponent = other as Component
		if rootElement == nil || otherComponent.rootElement == nil { return false }

		return rootElement!.canDiff(otherComponent.rootElement!)
	}
	
	public override func applyDiff(other: Element) {
		if other === self { return }

		let otherComponent = other as Component
		if rootElement == nil || otherComponent.rootElement == nil { return }

		hostView = otherComponent.hostView

		rootElement!.applyDiff(otherComponent.rootElement!)

		super.applyDiff(other)
	}
	
	public override func realize(parentView: ViewType) {
		addToView(parentView)
	}
	
	public override func derealize() {
		getContentView()?.removeFromSuperview()
	}
	
	public override func getContentView() -> ViewType? {
		return rootElement?.getContentView()
	}
}
