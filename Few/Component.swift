//
//  Component.swift
//  Few
//
//  Created by Josh Abernathy on 8/1/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import AppKit

class RealizedElement {
	let element: Element
	let view: ViewType?

	init(element: Element, view: ViewType?) {
		self.element = element
		self.view = view
	}
}

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

	private var rootRealizedElement: RealizedElement?

	private var hostView: ViewType?

	private let renderFn: ((Component<S>, S) -> Element)?

	/// Initializes the component with its initial state. The render function 
	/// takes the current state of the component and returns the element which 
	/// represents that state.
	public init(initialState: S) {
		self.state = initialState
	}

	public init(render: (Component<S>, S) -> Element, initialState: S) {
		self.renderFn = render
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
		if rootRealizedElement == nil { return }

		let newRoot = render(state)
		let oldRoot = rootRealizedElement!

		// If we can diff then apply it. Otherwise we just swap out the entire
		// hierarchy.
		if newRoot.canDiff(oldRoot.element) {
			if let rootView = oldRoot.view {
				newRoot.applyDiff(rootView, other: oldRoot.element)
			}

			rootRealizedElement = RealizedElement(element: newRoot, view: oldRoot.view)
		} else {
			oldRoot.element.derealize()
			if let hostView = hostView {
				let realizedView = newRoot.realize()
				if let view = realizedView {
					newRoot.applyDiff(view, other: newRoot)
				}
				rootRealizedElement = RealizedElement(element: newRoot, view: realizedView)
			}
		}
		
		componentDidUpdate()
	}

	/// Update the component without changing any state.
	public func forceUpdate() {
		update()
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
		precondition(hostView == nil, "\(self) has already been added to a view. Remove it before adding it to a new view.")
		
		componentWillRealize()
		
		hostView = view

		performInitialRender()
		
		componentDidRealize()
	}

	private func performInitialRender() {
		let rootElement = render(state)
		rootElement.frame = hostView!.bounds
		let realizedView = rootElement.realize()
		if let view = realizedView {
			rootElement.applyDiff(view, other: rootElement)
		}

		rootRealizedElement = RealizedElement(element: rootElement, view: realizedView)

		if let realizedView = realizedView {
			realizedView.autoresizingMask = .ViewWidthSizable | .ViewHeightSizable
			hostView?.addSubview(realizedView)
		}
	}
	
	/// Remove the component from its host view.
	public func remove() {
		componentWillDerealize()
		
		rootRealizedElement?.element.derealize()
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

	public func replaceState(state: S) {
		updateState(const(state))
	}

	/// Get the host view of the component.
	public func getHostView() -> ViewType? {
		return hostView
	}
	
	// MARK: Element
	
	public override func canDiff(other: Element) -> Bool {
		if !super.canDiff(other) { return false }
		
		let otherComponent = other as Component
		if rootRealizedElement == nil || otherComponent.rootRealizedElement == nil { return false }

		return rootRealizedElement!.element.canDiff(otherComponent.rootRealizedElement!.element)
	}
	
	public override func applyDiff(view: ViewType, other: Element) {
		if other === self { return }

		let otherComponent = other as Component
		hostView = otherComponent.hostView

		if rootRealizedElement == nil || otherComponent.rootRealizedElement == nil { return }

		rootRealizedElement!.element.applyDiff(view, other: otherComponent.rootRealizedElement!.element)

		super.applyDiff(view, other: other)
	}
	
	public override func realize() -> ViewType? {
		let element = render(state)
		return element.realize()
	}
	
	public override func derealize() {
		
	}
}

public func noLayout(container: Container, elements: [Element]) {}

public func alignLefts(origin: CGFloat)(container: Container, elements: [Element]) {
	for el in elements {
		el.frame.origin.x = origin
	}
}

public func verticalStack(padding: CGFloat)(container: Container, elements: [Element]) {
	var y = container.frame.size.height - padding;
	for el in elements {
		y -= el.frame.size.height + padding
		el.frame.origin.y = y
	}
}

public func horizontalStack(padding: CGFloat)(container: Container, elements: [Element]) {
	var x = padding
	for el in elements {
		el.frame.origin.x = x
		x += el.frame.size.width + padding
	}
}

public func offset(amount: CGPoint)(container: Container, elements: [Element]) {
	for el in elements {
		el.frame = CGRectOffset(el.frame, amount.x, amount.y)
	}
}

infix operator >-- { associativity left }
public func >--(f: (Container, [Element]) -> (), g: (Container, [Element]) -> ()) -> ((Container, [Element]) -> ()) {
	return { container, elements in
		f(container, elements)
		g(container, elements)
	}
}
