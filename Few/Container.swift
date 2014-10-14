//
//  Container.swift
//  Few
//
//  Created by Josh Abernathy on 8/27/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import AppKit

public func diffElementLists(oldList: [Element], newList: [Element], diffMatches: Bool) -> (add: [Element], remove: [Element]) {
	var add = [Element]()
	var remove = [Element]()

	var theirChildrenByKey = childrenByKey(oldList)

	var childQueue = oldList

	// We want to reuse children as much as possible. First we check for
	// matches by key, and then simply by order.
	for child in newList {
		var match: Element?
		// First try to find a match based on the key.
		if let key = child.key {
			var matchingChildren = theirChildrenByKey[key]
			if let matchingChildren = matchingChildren {
				if matchingChildren.count > 0 {
					match = matchingChildren[0]
					var c = matchingChildren
					c.removeAtIndex(0)
					theirChildrenByKey[key] = c
				}
			}
		}

		// If that fails and we still have new children, use one of those.
		while match == nil && childQueue.count > 0 {
			match = childQueue[0]
			childQueue.removeAtIndex(0)

			// It has a key and we didn't already match it up.
			if let key = match!.key {
				match = nil
			}
		}

		// If we have a match/pair then do the diff dance.
		if let match = match {
			if child.canDiff(match) {
				if diffMatches {
					child.applyDiff(match)
				}
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
		if let key = child.key {
			if let children = theirChildrenByKey[key] {
				if children.count > 0 {
					remove.append(child)
				}
			}
		} else {
			remove.append(child)
		}
	}

	return (add: add, remove: remove)
}

private func childrenByKey(children: [Element]) -> [String: [Element]] {
	var childrenByKey = [String: [Element]]()
	for child in children {
		if let key = child.key {
			var existing = childrenByKey[key]
			if let existing = existing {
				var e = existing
				e.append(child)
				childrenByKey[key] = e
			} else {
				childrenByKey[key] = [child]
			}
		}
	}

	return childrenByKey
}

/// Containers (surprise!) contain other elements.
///
/// They diff their children using essentially two different passes:
///   1. Pair up children with the same key and diff them if possible.
///   2. Diff remaining children by order.
public class Container: Element {
	private var children: [Element]

	private var containerView: ViewType?

	private var layout: ((Container, [Element]) -> ())?

	public convenience init(children: [Element], layout: (Container, [Element]) -> ()) {
		self.init(children)
		self.layout = layout
	}

	public init(_ children: [Element]) {
		self.children = children
	}

	public convenience init(_ children: Element...) {
		self.init(children)
	}

	// MARK: Element

	public override func applyDiff(other: Element) {
		let otherContainer = other as Container
		containerView = otherContainer.containerView

		super.applyDiff(other)

		let (add, remove) = diffElementLists(otherContainer.children, children, true)

		if let containerView = containerView {
			if let realizeFn = realizeInComponent {
				for child in add {
					realizeFn(child, containerView)
				}
			}
		}

		for child in remove {
			child.derealize()
		}

		layout?(self, children)
	}

	public override func realize<S>(component: Component<S>, parentView: ViewType) {
		let view = ViewType(frame: frame)
		containerView = view

		layout?(self, children)
		
		for element in children {
			element.realize(component, parentView: view)
		}
		
		super.realize(component, parentView: parentView)
	}

	public override func derealize() {
		for element in children {
			element.derealize()
		}
		
		super.derealize()
	}
	
	public override func getContentView() -> ViewType? {
		return containerView
	}
}
