//
//  Diffing.swift
//  Few
//
//  Created by Josh Abernathy on 11/11/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation

/// An Element which has been realized and now has an associated view.
public class RealizedElement {
	let element: Element
	let children: [RealizedElement]
	let view: ViewType?

	public init(element: Element, children: [RealizedElement], view: ViewType?) {
		self.element = element
		self.children = children
		self.view = view
	}
}

/// The result of an element list diff.
public struct ElementListDiff {
	public let add: [Element]
	public let remove: [RealizedElement]
	public let diff: [(old: RealizedElement, `new`: Element)]
}

/// Group the list of elements by their key.
private func groupElementsByKey(children: [RealizedElement]) -> [String: [RealizedElement]] {
	var childrenByKey: [String: [RealizedElement]] = [:]
	for child in children {
		if let key = child.element.key {
			let existing = childrenByKey[key]
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

/// Diff the list of realized elements and a new list of elements.
public func diffElementLists(oldList: [RealizedElement], newList: [Element]) -> ElementListDiff {
	var add: [Element] = []
	var remove: [RealizedElement] = []
	var diff: [(old: RealizedElement, `new`: Element)] = []

	var existingChildrenByKey = groupElementsByKey(oldList)

	var childQueue = oldList

	// We want to reuse children as much as possible. First we check for
	// matches by key, and then simply by order.
	for child in newList {
		var match: RealizedElement?
		// First try to find a match based on the key.
		if let key = child.key {
			let matchingChildren = existingChildrenByKey[key]
			if var matchingChildren = matchingChildren {
				if matchingChildren.count > 0 {
					match = matchingChildren[0]
					matchingChildren.removeAtIndex(0)
					existingChildrenByKey[key] = matchingChildren
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
			if var children = existingChildrenByKey[key] {
				if children.count > 0 {
					remove.append(child)
					children.removeAtIndex(0)
					existingChildrenByKey[key] = children
				}
			}
		} else {
			remove.append(child)
		}
	}

	return ElementListDiff(add: add, remove: remove, diff: diff)
}

/// Realize the element and its children recursively.
internal func realizeElementRecursively(element: Element) -> RealizedElement {
	let view = element.realize()
	if let view = view {
		element.applyDiff(view, other: element)
	}

	let children = element.getChildren()
	let realizedChildren = children.map(realizeElementRecursively)
	if let view = view {
		for child in realizedChildren {
			view.addSubview <^> child.view
		}
	}

	return RealizedElement(element: element, children: realizedChildren, view: view)
}

/// Diff the old element and new elements and their children recursively.
internal func diffElementRecursively(oldElement: RealizedElement, newElement: Element) -> RealizedElement {
	if let view = oldElement.view {
		newElement.applyDiff(view, other: oldElement.element)
	}

	let listDiff = diffElementLists(oldElement.children, newElement.getChildren())
	for element in listDiff.remove {
		element.element.derealize()
		element.view?.removeFromSuperview()
	}

	let newRealizedElements = listDiff.add.map(realizeElementRecursively)
	if let view = oldElement.view {
		for element in newRealizedElements {
			view.addSubview <^> element.view
		}
	}

	var existingRealizedElements: [RealizedElement] = []
	for (old, `new`) in listDiff.diff {
		let realizedElement = diffElementRecursively(old, `new`)
		existingRealizedElements.append(realizedElement)
	}

	return RealizedElement(element: newElement, children: existingRealizedElements + newRealizedElements, view: oldElement.view)
}
