//
//  Component.swift
//  Few
//
//  Created by Josh Abernathy on 8/1/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import AppKit

public class RealizedElement {
	let element: Element
	let children: [RealizedElement]
	let view: ViewType?

	init(element: Element, children: [RealizedElement], view: ViewType?) {
		self.element = element
		self.children = children
		self.view = view
	}
}

internal struct ElementListDiff {
	let add: [Element]
	let remove: [RealizedElement]
	let diff: [(old: RealizedElement, `new`: Element)]
}

private func childrenByKey(children: [RealizedElement]) -> [String: [RealizedElement]] {
	var childrenByKey = [String: [RealizedElement]]()
	for child in children {
		if let key = child.element.key {
			var existing = childrenByKey[key]
			if var existing = existing {
				existing.append(child)
				childrenByKey[key] = existing
			} else {
				childrenByKey[key] = [child]
			}
		}
	}

	return childrenByKey
}

internal func diffElementLists(oldList: [RealizedElement], newList: [Element]) -> ElementListDiff {
	var add: [Element] = []
	var remove: [RealizedElement] = []
	var diff: [(old: RealizedElement, `new`: Element)] = []

	var theirChildrenByKey = childrenByKey(oldList)

	var childQueue = oldList

	// We want to reuse children as much as possible. First we check for
	// matches by key, and then simply by order.
	for child in newList {
		var match: RealizedElement?
		// First try to find a match based on the key.
		if let key = child.key {
			var matchingChildren = theirChildrenByKey[key]
			if var matchingChildren = matchingChildren {
				if matchingChildren.count > 0 {
					match = matchingChildren[0]
					matchingChildren.removeAtIndex(0)
					theirChildrenByKey[key] = matchingChildren
				}
			}
		}

		// If that fails and we still have new children, use one of those.
		while match == nil && childQueue.count > 0 {
			match = childQueue[0]
			childQueue.removeAtIndex(0)

			// It has a key and we didn't already match it up.
			if let key = match!.element.key {
				match = nil
			}
		}

		// If we have a match/pair then do the diff dance.
		if let match = match {
			if child.canDiff(match.element) {
				diff.append(old: match, `new`: child)
			} else {
				remove.append(match)
				add.append(child)
			}
		} else {
			// If we didn't find anything we could reuse, then we need to
			// realize the new child.
			add.append(child)
		}
	}

	// Anything left over at this point must be old.
	for child in childQueue {
		if let key = child.element.key {
			if var children = theirChildrenByKey[key] {
				if children.count > 0 {
					remove.append(child)
					children.removeAtIndex(0)
					theirChildrenByKey[key] = children
				}
			}
		} else {
			remove.append(child)
		}
	}

	return ElementListDiff(add: add, remove: remove, diff: diff)
}

func realizeElementRecursively(element: Element, hostView: ViewType?) -> RealizedElement {
	let view = element.realize()
	if let view = view {
		element.applyDiff(view, other: element)
		hostView?.addSubview(view)
	}

	let children = element.getChildren()
	let realizedChildren = children.map { realizeElementRecursively($0, view ?? hostView) }

	return RealizedElement(element: element, children: realizedChildren, view: view)
}

func diffElementRecursively(oldElement: RealizedElement, newElement: Element, hostView: ViewType?) -> RealizedElement {
	if let view = oldElement.view {
		newElement.applyDiff(view, other: oldElement.element)
	}

	let listDiff = diffElementLists(oldElement.children, newElement.getChildren())
	for element in listDiff.remove {
		element.element.derealize()
		element.view?.removeFromSuperview()
	}

	let newRealizedElements = listDiff.add.map { realizeElementRecursively($0, hostView) }

	var existingRealizedElements: [RealizedElement] = []
	for (old, `new`) in listDiff.diff {
		let realizedElement = diffElementRecursively(old, `new`, old.view ?? hostView)
		existingRealizedElements.append(realizedElement)
	}

	return RealizedElement(element: newElement, children: existingRealizedElements + newRealizedElements, view: oldElement.view)
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

	private func realizeNewRoot(element: Element) -> RealizedElement {
		element.frame = hostView?.bounds ?? frame

		let realizedElement = realizeElementRecursively(element, hostView)
		if let realizedView = realizedElement.view {
			realizedView.autoresizingMask = .ViewWidthSizable | .ViewHeightSizable
			hostView?.addSubview(realizedView)
		}

		return realizedElement
	}

	private func update() {
		let newRoot = render(state)
		let oldRoot = rootRealizedElement
		if let oldRoot = oldRoot {
			// If we can diff then apply it. Otherwise we just swap out the 
			// entire hierarchy.
			if newRoot.canDiff(oldRoot.element) {
				rootRealizedElement = diffElementRecursively(oldRoot, newRoot, hostView)
			} else {
				oldRoot.element.derealize()
				oldRoot.view?.removeFromSuperview()
				rootRealizedElement = realizeNewRoot(newRoot)
			}
		} else {
			rootRealizedElement = realizeNewRoot(newRoot)
		}
		
		componentDidUpdate()
	}

	/// Update the component without changing any state.
	public func forceUpdate() {
		update()
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

	/// Add the component to the given view. A component can only be added to 
	/// one view at a time.
	public func addToView(view: ViewType) {
		precondition(hostView == nil, "\(self) has already been added to a view. Remove it before adding it to a new view.")
		
		componentWillRealize()
		
		hostView = view

		update()

		componentDidRealize()
	}

	/// Remove the component from its host view.
	public func remove() {
		componentWillDerealize()

		rootRealizedElement?.view?.removeFromSuperview()
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

		// Use `unsafeBitCast` instead of `as` to avoid a runtime crash.
		let otherComponent = unsafeBitCast(other, Component.self)
		if rootRealizedElement == nil || otherComponent.rootRealizedElement == nil { return false }

		return rootRealizedElement!.element.canDiff(otherComponent.rootRealizedElement!.element)
	}
	
	public override func applyDiff(view: ViewType, other: Element) {
		// Use `unsafeBitCast` instead of `as` to avoid a runtime crash.
		let otherComponent = unsafeBitCast(other, Component.self)
		hostView = otherComponent.hostView

		if rootRealizedElement == nil || otherComponent.rootRealizedElement == nil { return }

		rootRealizedElement!.element.applyDiff(view, other: otherComponent.rootRealizedElement!.element)

		super.applyDiff(view, other: other)
	}
	
	public override func realize() -> ViewType? {
		update()
		return rootRealizedElement?.view
	}
	
	public override func derealize() {
		remove()
	}
}
