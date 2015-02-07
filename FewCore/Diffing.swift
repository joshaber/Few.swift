//
//  Diffing.swift
//  Few
//
//  Created by Josh Abernathy on 11/11/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation

/// The result of an element list diff.
public struct ElementListDiff {
	public let add: [Element]
	public let remove: [Element]
	public let diff: [(old: Element, `new`: Element)]
}

/// Group the list of elements by their key.
private func groupElementsByKey(children: [Element]) -> [String: [Element]] {
	var childrenByKey: [String: [Element]] = [:]
	for child in children {
		if let key = child.key {
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

/// Diff the list of old elements and a new list of elements.
public func diffElementLists(oldList: [Element], newList: [Element]) -> ElementListDiff {
	var add: [Element] = []
	var remove: [Element] = []
	var diff: [(old: Element, `new`: Element)] = []

	var existingChildrenByKey = groupElementsByKey(oldList)

	var childQueue = oldList

	// We want to reuse children as much as possible. First we check for
	// matches by key, and then simply by order.
	for child in newList {
		var match: Element?
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
			if let key = match!.key {
				match = nil
			}
		}

		// If we have a match/pair then do the diff dance.
		if let match = match {
			if child.canDiff(match) {
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
		if let key = child.key {
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
