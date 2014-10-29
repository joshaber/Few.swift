//
//  Container.swift
//  Few
//
//  Created by Josh Abernathy on 8/27/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import AppKit

internal struct ElementDiff {
	let add: [RealizedElement]
	let remove: [RealizedElement]
	let diff: [(old: RealizedElement, `new`: RealizedElement)]
}

internal func diffElementLists(oldList: [RealizedElement], newList: [RealizedElement]) -> ElementDiff {
	var add = [RealizedElement]()
	var remove = [RealizedElement]()
	var diff: [(old: RealizedElement, `new`: RealizedElement)] = []

	var theirChildrenByKey = childrenByKey(oldList)

	var childQueue = oldList

	// We want to reuse children as much as possible. First we check for
	// matches by key, and then simply by order.
	for child in newList {
		var match: RealizedElement?
		// First try to find a match based on the key.
		if let key = child.element.key {
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
			if let key = match!.element.key {
				match = nil
			}
		}

		// If we have a match/pair then do the diff dance.
		if let match = match {
			if child.element.canDiff(match.element) {
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
			if let children = theirChildrenByKey[key] {
				if children.count > 0 {
					remove.append(child)
					var c = children
					c.removeAtIndex(0)
					theirChildrenByKey[key] = c
				}
			}
		} else {
			remove.append(child)
		}
	}

	return ElementDiff(add: add, remove: remove, diff: diff)
}

private func childrenByKey(children: [RealizedElement]) -> [String: [RealizedElement]] {
	var childrenByKey = [String: [RealizedElement]]()
	for child in children {
		if let key = child.element.key {
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

class ContainerView: NSView {
	var realizedElements: [RealizedElement] = []

	required init?(coder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
	}
}

/// Containers (surprise!) contain other elements.
///
/// They diff their children using essentially two different passes:
///   1. Pair up children with the same key and diff them if possible.
///   2. Diff remaining children by order.
public class Container: Element {
	private let children: [Element]

	private let layout: ((Container, [Element]) -> ())?

	public init(children: [Element], layout: ((Container, [Element]) -> ())?) {
		self.layout = layout
		self.children = children
	}

	public convenience init(_ children: [Element]) {
		self.init(children: children, nil)
	}

	public convenience init(_ children: Element...) {
		self.init(children)
	}

	// MARK: Element

	public override func applyDiff(view: ViewType, other: Element) {
		let otherContainer = other as Container
		let containerView = view as ContainerView

		super.applyDiff(view, other: other)

		let p = children.map { RealizedElement(element: $0, view: nil) }
		let result = diffElementLists(containerView.realizedElements, p)

		for child in result.add {
			let view = child.element.realize()
			containerView.addSubview <*> view
		}

		for child in result.remove {
			child.view?.removeFromSuperview()
			child.element.derealize()
		}

		for pair in result.diff {
			let (old, `new`) = pair
			if let view = old.view {
				`new`.element.applyDiff(view, other: old.element)
			}
		}

		layout?(self, children)
	}

	public override func realize() -> ViewType? {
		let containerView = ContainerView(frame: frame)

		layout?(self, children)

		var realizedElements: [RealizedElement] = []
		for element in children {
			let realizedView = element.realize()
			containerView.addSubview <*> realizedView
			realizedElements.append(RealizedElement(element: element, view: realizedView))
		}

		containerView.realizedElements = realizedElements

		return containerView
	}

	public override func derealize() {
		for element in children {
			element.derealize()
		}
		
		super.derealize()
	}
}
