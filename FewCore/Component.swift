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

#if os(OSX)
import AppKit
#endif

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
	public private(set) var state: S

	private let renderFn: ((Component, S) -> Element)?

	private let didRealizeFn: (Component -> ())?

	private var renderQueued: Bool = false

	/// Is the component a root?
	private var root = false

	/// Is the component currently rendering?
	private var rendering = false

	private var parent: RealizedElement?

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

	public func render() -> Element {
		if let renderFn = renderFn {
			return renderFn(self, state)
		} else {
			return Empty()
		}
	}

	/// Render the component without changing any state.
	///
	/// Note that unlike Component.updateState, this doesn't enqueue a render to 
	/// be performed at the end of the runloop. Instead it immediately
	/// re-renders.
	final public func forceRender() {
		rerender()
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
	public func componentShouldRender(previousSelf: Component, previousState: S) -> Bool {
		return true
	}

	private var realizedSelf: RealizedElement? {
		return parent?.realizedElementForElement(self)
	}
	
	// MARK: -

	/// Add the component to the given view. A component can only be added to 
	/// one view at a time.
	public func addToView(hostView: ViewType) {
		root = true
		frame = hostView.bounds
		parent = RealizedElement(element: self, view: hostView, parent: nil)

		realize(parent)
		layout()

#if os(OSX)
		configureViewForFrameChangedEvent(hostView)
#endif
	}

#if os(OSX)
	final private func configureViewForFrameChangedEvent(hostView: ViewType) {
		hostView.postsFrameChangedNotifications = true
		hostView.autoresizesSubviews = false

		frameChangedTrampoline.action = { [weak self] in
			if let strongSelf = self {
				strongSelf.hostViewFrameChanged(hostView)
			}
		}

		NSNotificationCenter.defaultCenter().addObserver(frameChangedTrampoline, selector: frameChangedTrampoline.selector, name: NSViewFrameDidChangeNotification, object: hostView)
	}

	final private func hostViewFrameChanged(hostView: ViewType) {
		frame.size = hostView.frame.size
		realizedSelf?.markNeedsLayout()
		// A full re-render is less than ideal :|
		forceRender()
	}
#endif

	/// Remove the component from its host view.
	public func remove() {
#if os(OSX)
		NSNotificationCenter.defaultCenter().removeObserver(frameChangedTrampoline, name: NSViewFrameDidChangeNotification, object: nil)
		frameChangedTrampoline.action = nil
#endif

		derealize()
		root = false
	}
	
	/// Update the state using the given function.
	final public func updateState(@noescape fn: S -> S) {
		precondition(NSThread.isMainThread(), "Updating component state on a background thread. Donut do that!")

		state = fn(state)
		
		enqueueRender()
	}

	final public func modifyState(@noescape fn: inout S -> ()) {
		updateState { (var s) in
			fn(&s)
			return s
		}
	}

	final private func enqueueRender() {
		if renderQueued { return }

		if let root = realizedSelf?.findRoot() where root.element.isRenderQueued {
			return
		}

		renderQueued = true

		let observer = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, CFRunLoopActivity.BeforeWaiting.rawValue, 0, 0) { _, activity in
			self.renderQueued = false
			self.rerender()
		}
		CFRunLoopAddObserver(CFRunLoopGetMain(), observer, kCFRunLoopCommonModes)
	}

	final private func rerender() {
		applyDiff(self, realizedSelf: realizedSelf)
	}

	// MARK: Element
	
	public override func applyDiff(old: Element, realizedSelf: RealizedElement?) {
		let oldComponent = old as! Component
		let shouldRender = componentShouldRender(oldComponent, previousState: oldComponent.state)

		parent = oldComponent.parent
		root = oldComponent.root
		state = oldComponent.state
		frameChangedTrampoline = oldComponent.frameChangedTrampoline

		rendering = true

		if shouldRender {
			updateChildren()
			super.applyDiff(old, realizedSelf: realizedSelf)
		}

		realizedSelf?.layoutFromRoot()

		rendering = false

		componentDidRender()
	}

	internal override var isRoot: Bool {
		return root
	}

	internal override var isRendering: Bool {
		return rendering
	}

	internal override var isRenderQueued: Bool {
		return renderQueued
	}

	private func updateChildren() {
		let element = render()
		if root {
			// The root element should flex to fill its container.
			element.flex = 1
		}
		children = [ element ]
	}

	private func layout() {
		realizedSelf?.layoutFromRoot()
	}
	
	public override func realize(parent: RealizedElement?) -> RealizedElement {
		componentWillRealize()

		self.parent = parent

		updateChildren()

		let realizedElement = super.realize(parent)

		componentDidRealize()

		return realizedElement
	}

	public override func derealize() {
		componentWillDerealize()

		parent = nil

		componentDidDerealize()
	}
}

extension Component {
	final public func findView(element: Element) -> ViewType? {
		return findViewRecursively(realizedSelf) { $0.element === element }
	}

	/// Find the view with the given key. This will only find views for elements
	/// which have been realized.
	final public func findViewWithKey(key: String) -> ViewType? {
		return findViewRecursively(realizedSelf) { $0.element.key == key }
	}

	final private func findViewRecursively(rootElement: RealizedElement?, predicate: RealizedElement -> Bool) -> ViewType? {
		if let rootElement = rootElement {
			if predicate(rootElement) {
				return rootElement.view
			} else {
				for element in rootElement.children {
					if let result = findViewRecursively(element, predicate: predicate) {
						return result
					}
				}
			}
		}

		return nil
	}
}
