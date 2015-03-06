//
//  Component.swift
//  Few
//
//  Created by Josh Abernathy on 8/1/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import CoreGraphics
import SwiftBox

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
	private var state: S

	private var rootElement: Element?

	private var realizedRoot: RealizedElement?

	private let renderFn: ((Component, S) -> Element)?

	private let didRealizeFn: (Component -> ())?

	private var renderQueued: Bool = false

	/// Is the component a root?
	private var root = false

	private var frameChangedTrampoline = TargetActionTrampoline()

	/// Initializes the component with its initial state. The render function
	/// takes the current state of the component and returns the element which 
	/// represents that state.
	public init(initialState: S) {
		self.state = initialState
		self.renderFn = nil
		self.didRealizeFn = nil
	}

	public init(initialState: S, render: (Component, S) -> Element) {
		self.renderFn = render
		self.state = initialState
		self.didRealizeFn = nil
	}

	public init(initialState: S, didRealize: Component -> (), render: (Component, S) -> Element) {
		self.renderFn = render
		self.state = initialState
		self.didRealizeFn = didRealize
	}

	// MARK: Lifecycle

	public func render(state: S) -> Element {
		if let renderFn = renderFn {
			return renderFn(self, state)
		} else {
			return Empty()
		}
	}

	final private func render() {
		if let rootElement = rootElement {
			applyDiff(self, realizedSelf: nil)
		}
	}

	final private func realizeNewRoot(newRoot: Element) {
		let realized = newRoot.realize()

		configureViewToAutoresize(realized.view)

		realizedRoot?.view.removeFromSuperview()
		realizedRoot = realized
	}

	final private func renderNewRoot() {
		let newRoot = render(state)
		newRoot.frame = frame
		newRoot.margin = margin
		newRoot.padding = padding
		newRoot.hidden = hidden
		newRoot.alpha = alpha
		newRoot.selfAlignment = selfAlignment
		newRoot.flex = flex

		let node = newRoot.assembleLayoutNode()
		let layout: Layout
		if root {
			layout = node.layout(maxWidth: frame.size.width)
		} else {
			layout = node.layout()
		}

		newRoot.applyLayout(layout)

		// If we're not the root then we should expect the root to set our 
		// frame. We shouldn't size or position ourselves.
		if !root {
			newRoot.frame = frame
		}

		if let rootElement = rootElement {
			if newRoot.canDiff(rootElement) {
				newRoot.applyDiff(rootElement, realizedSelf: realizedRoot)
			} else {
				let superview = realizedRoot!.view.superview!
				rootElement.derealize()

				realizeNewRoot(newRoot)
				superview.addSubview(realizedRoot!.view)

				rootElement.elementDidRealize(realizedRoot!)
			}

			componentDidRender()
		}

		rootElement = newRoot
	}

	/// Render the component without changing any state.
	///
	/// Note that unlike Component.updateState, this doesn't enqueue a render to 
	/// be performed at the end of the runloop. Instead it immediately 
	/// re-renders.
	final public func forceRender() {
		render()
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
	public func addToView(hostView: ViewType) {
		root = true
		frame = hostView.bounds
		performInitialRenderIfNeeded()
		realizeRootIfNeeded()
		hostView.addSubview(realizedRoot!.view)
		rootElement?.elementDidRealize(realizedRoot!)

		hostView.postsFrameChangedNotifications = true
		realizedRoot!.view.autoresizesSubviews = false

		frameChangedTrampoline.action = { [weak self] in
			if let strongSelf = self {
				strongSelf.hostViewFrameChanged(hostView)
			}
		}
		NSNotificationCenter.defaultCenter().addObserver(frameChangedTrampoline, selector: frameChangedTrampoline.selector, name: NSViewFrameDidChangeNotification, object: hostView)
	}

	final private func hostViewFrameChanged(hostView: ViewType) {
		frame.size = hostView.frame.size
		// A full re-render is less than ideal :|
		renderNewRoot()
	}

	/// Remove the component from its host view.
	public func remove() {
		NSNotificationCenter.defaultCenter().removeObserver(frameChangedTrampoline, name: NSViewFrameDidChangeNotification, object: nil)
		frameChangedTrampoline.action = nil

		derealize()
		root = false
	}
	
	/// Update the state using the given function.
	final public func updateState(fn: S -> S) {
		precondition(NSThread.isMainThread(), "Component.updateState called on a background thread. Donut do that!")

		let oldState = state
		state = fn(oldState)
		
		if componentShouldRender(oldState, newState: state) {
			enqueueRender()
		}
	}

	final public func modifyState(fn: inout S -> ()) {
		precondition(NSThread.isMainThread(), "Component.modifyState called on a background thread. Donut do that!")

		let oldState = state
		fn(&state)

		if componentShouldRender(oldState, newState: state) {
			enqueueRender()
		}
	}

	final private func enqueueRender() {
		if renderQueued { return }

		renderQueued = true

		let observer = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, CFRunLoopActivity.Exit.rawValue, 0, 0) { _, _ in
			self.renderQueued = false
			self.render()
		}
		CFRunLoopAddObserver(CFRunLoopGetMain(), observer, kCFRunLoopCommonModes)
	}

	/// Get the current state of the component.
	final public func getState() -> S {
		return state
	}

	final public func findView(element: Element) -> ViewType? {
		if let realizedElement = realizedRoot {
			return findViewRecursively(element, rootElement: realizedElement)
		} else {
			return nil
		}
	}

	final private func findViewRecursively(element: Element, rootElement: RealizedElement) -> ViewType? {
		if rootElement.element === element { return rootElement.view }

		for child in rootElement.children {
			let result = findViewRecursively(element, rootElement: child)
			if result != nil { return result }
		}

		return nil
	}

	/// Find the view with the given key. This will only find views for elements
	/// which have been realized.
	final public func findViewWithKey(key: String) -> ViewType? {
		if let realizedElement = realizedRoot {
			return findViewWithKeyRecursive(key, rootElement: realizedElement)
		} else {
			return nil
		}
	}

	final private func findViewWithKeyRecursive(key: String, rootElement: RealizedElement) -> ViewType? {
		if rootElement.element.key == key { return rootElement.view }

		for element in rootElement.children {
			let result = findViewWithKeyRecursive(key, rootElement: element)
			if result != nil { return result }
		}

		return nil
	}
	
	// MARK: Element
	
	public override func applyDiff(old: Element, realizedSelf: RealizedElement?) {
		super.applyDiff(old, realizedSelf: realizedSelf)

		// Use `unsafeBitCast` instead of `as` to avoid a runtime crash.
		let oldComponent = unsafeBitCast(old, Component.self)

		root = oldComponent.root
		state = oldComponent.state
		rootElement = oldComponent.rootElement
		realizedRoot = oldComponent.realizedRoot

		renderNewRoot()
	}
	
	public override func realize() -> RealizedElement {
		performInitialRenderIfNeeded()
		realizeRootIfNeeded()
		return RealizedElement(element: self, view: realizedRoot!.view)
	}

	public override func derealize() {
		componentWillDerealize()

		rootElement?.derealize()
		rootElement = nil

		realizedRoot?.view.removeFromSuperview()
		realizedRoot = nil

		componentDidDerealize()
	}

	final private func performInitialRenderIfNeeded() {
		if rootElement == nil {
			renderNewRoot()
		}
	}

	final private func realizeRootIfNeeded() {
		if realizedRoot == nil {
			componentWillRealize()
			realizeNewRoot(rootElement!)
			didRealizeFn?(self)
			componentDidRealize()
		}
	}

	internal override func assembleLayoutNode() -> Node {
		performInitialRenderIfNeeded()

		return rootElement!.assembleLayoutNode()
	}

	override func applyLayout(layout: Layout) {
		frame = layout.frame

		rootElement?.applyLayout(layout)
	}

	public override func elementDidRealize(realizedSelf: RealizedElement) {
		super.elementDidRealize(realizedSelf)

		rootElement?.elementDidRealize(realizedRoot!)
	}
}
