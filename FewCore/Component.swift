//
//  Component.swift
//  Few
//
//  Created by Josh Abernathy on 8/1/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import CoreGraphics

/// Components are stateful elements and the bridge between Few and
/// AppKit/UIKit.
///
/// Simple components can be created without subclassing. More complex
/// components will need to subclass it in order to add lifecycle events or 
/// customize its behavior further.
///
/// By default whenever the component's state is changed, it re-renders itself 
/// by calling the `render` function passed in to its init. But subclasses can
/// optimize this by implementing `componentShouldRender`.
public class Component<S>: Element {
	/// The state on which the component depends.
	private var state: S

	private var rootRealizedElement: RealizedElement?

	private var hostView: ViewType?

	private let renderFn: ((Component<S>, S) -> Element)?

	private var renderQueued: Bool = false

	private var effectiveFrame: CGRect {
		return hostView?.bounds ?? frame
	}

	/// Initializes the component with its initial state. The render function 
	/// takes the current state of the component and returns the element which 
	/// represents that state.
	public init(initialState: S) {
		self.state = initialState
		super.init()
	}

	public init(render: (Component<S>, S) -> Element, initialState: S) {
		self.renderFn = render
		self.state = initialState
		super.init()
	}

	public required init(copy: Element, frame: CGRect, hidden: Bool, alpha: CGFloat, key: String?) {
		let component = copy as Component
		state = component.state
		rootRealizedElement = component.rootRealizedElement
		renderFn = component.renderFn
		super.init(copy: copy, frame: frame, hidden: hidden, alpha: alpha, key: key)
	}

	// MARK: Lifecycle

	public func render(state: S) -> Element {
		if let renderFn = renderFn {
			return renderFn(self, state)
		} else {
			return Empty()
		}
	}

	private func realizeNewRoot(element: Element) -> RealizedElement {
		let sizedElement = element.frame(effectiveFrame)
		let realizedElement = realizeElementRecursively(sizedElement)
		if let realizedView = realizedElement.view {
			configureViewToAutoresize(realizedView)
			hostView?.addSubview(realizedView)
		}

		return realizedElement
	}

	private func render() -> Element {
		return renderWithRootRealizedElement(rootRealizedElement)
	}

	private func renderWithRootRealizedElement(realizedElement: RealizedElement?) -> Element {
		let newRoot = render(state)
		if let realizedElement = realizedElement {
			// If we can diff then apply it. Otherwise we just swap out the
			// entire hierarchy.
			if newRoot.canDiff(realizedElement.element) {
				let rootWithFrame = newRoot.frame(effectiveFrame)
				rootRealizedElement = diffElementRecursively(realizedElement, rootWithFrame)
			} else {
				realizedElement.element.derealize()
				realizedElement.view?.removeFromSuperview()
				rootRealizedElement = realizeNewRoot(newRoot)
			}
		}

		componentDidRender()

		return newRoot
	}

	/// Render the component without changing any state.
	public func forceRender() {
		enqueueRender()
	}
	
	/// Called when the component will be realized and before the component is
	/// rendered for the first time.
	public func componentWillRealize() {}
	
	/// Called when the component has been realized and after the component has
	/// been rendered for the first time.
	public func componentDidRealize() {}
	
	/// Called when the component is about to be derealized.
	public func componentWillDerealize() {}
	
	/// Called when the component has been derealized.
	public func componentDidDerealize() {}
	
	/// Called after the component has been rendered and diff applied.
	public func componentDidRender() {}
	
	/// Called when the state has changed but before the component is 
	/// re-rendered. This gives the component the chance to decide whether it 
	/// *should* based on the new state.
	///
	/// The default implementation always returns true.
	public func componentShouldRender(previousState: S, newState: S) -> Bool {
		return true
	}
	
	// MARK: -

	/// Add the component to the given view. A component can only be added to 
	/// one view at a time.
	public func addToView(view: ViewType) {
		precondition(hostView == nil, "\(self) has already been added to a view. Remove it before adding it to a new view.")

		hostView = view
		rootRealizedElement = realizeComponent()
	}

	private func realizeComponent() -> RealizedElement {
		componentWillRealize()

		let root = render()
		let realizedRoot = realizeNewRoot(root)

		componentDidRealize()

		return realizedRoot
	}

	/// Remove the component from its host view.
	public func remove() {
		componentWillDerealize()

		rootRealizedElement?.view?.removeFromSuperview()
		rootRealizedElement?.element.derealize()
		hostView = nil
		rootRealizedElement = nil
		
		componentDidDerealize()
	}
	
	/// Update the state using the given function.
	public func updateState(fn: S -> S) {
		precondition(NSThread.isMainThread(), "Component.updateState called on a background thread. Donut do that!")

		let oldState = state
		state = fn(oldState)
		
		if componentShouldRender(oldState, newState: state) {
			enqueueRender()
		}
	}

	private func enqueueRender() {
		if renderQueued { return }

		renderQueued = true

		let observer = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, CFRunLoopActivity.Exit.rawValue, 0, 0) { _, _ in
			self.renderQueued = false
			self.render()
		}
		CFRunLoopAddObserver(CFRunLoopGetMain(), observer, kCFRunLoopDefaultMode)
	}

	/// Get the current state of the component.
	public func getState() -> S {
		return state
	}

	/// Get the view with the given key.
	///
	/// This will be nil for elements which haven't been realized yet or haven't
	/// been returned from the render function.
	public func getView(#key: String) -> ViewType? {
		if let realizedElement = rootRealizedElement {
			return getViewRecursive(key, rootElement: realizedElement)
		} else {
			return nil
		}
	}

	private func getViewRecursive(key: String, rootElement: RealizedElement) -> ViewType? {
		if rootElement.element.key == key { return rootElement.view }

		for element in rootElement.children {
			let result = getViewRecursive(key, rootElement: element)
			if result != nil { return result }
		}

		return nil
	}
	
	// MARK: Element
	
	public override func applyDiff(view: ViewType, other: Element) {
		// Use `unsafeBitCast` instead of `as` to avoid a runtime crash.
		let otherComponent = unsafeBitCast(other, Component.self)
		hostView = otherComponent.hostView

		renderWithRootRealizedElement(otherComponent.rootRealizedElement)

		super.applyDiff(view, other: other)
	}
	
	public override func realize() -> ViewType? {
		let realizedRoot = realizeComponent()
		rootRealizedElement = realizedRoot
		return rootRealizedElement?.view
	}

	public override func derealize() {
		remove()
	}
}
