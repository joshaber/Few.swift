//
//  Container.swift
//  Few
//
//  Created by Josh Abernathy on 8/27/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import AppKit

public class Container: Element {
	private var children: [Element]

	private var containerView: NSView?
	
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

		let otherChildren = otherContainer.children

		let myChildrenByKey = childrenByKey(children)
		let theirChildrenByKey = childrenByKey(otherChildren)

		var usedKeys = [String: Void]()

		var childQueue = otherChildren

		// We want to reuse children as much as possible. First we check for
		// matches by key, and then simply by order.
		for child in children {
			var match: Element?
			// First try to find a match based on the key.
			if let key = child.key {
				match = theirChildrenByKey[key]
				usedKeys[key] = ()
			}

			// If that fails and we still have new children, use one of those.
			if match == nil && childQueue.count > 0 {
				match = childQueue[0]
				childQueue.removeAtIndex(0)

				// We already used this child when doing key matching, so don't
				// use it again.
				if let key = match!.key {
					if usedKeys[key] != nil {
						match = nil
					}
				}
			}

			// If we have a match/pair then do the diff dance.
			if let match = match {
				if child.canDiff(match) {
					child.applyDiff(match)
				} else {
					match.derealize()

					let component: Component<Any>? = getComponent()
					curry(child.realize) <^> component <*> containerView
				}
			} else {
				// If we didn't find anything we could reuse, then we need to
				// realize the new child.
				let component: Component<Any>? = getComponent()
				curry(child.realize) <^> component <*> containerView
			}
		}

		// Anything left over at this point must be old.
		for child in childQueue {
			child.derealize()
		}

		super.applyDiff(other)
	}

	private func childrenByKey(children: [Element]) -> [String: Element] {
		var childrenByKey = [String: Element]()
		for child in children {
			if let key = child.key {
				childrenByKey[key] = child
			}
		}

		return childrenByKey
	}

	public override func realize<S>(component: Component<S>, parentView: NSView) {
		let view = NSView(frame: frame)
		containerView = view
		
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
	
	public override func getContentView() -> NSView? {
		return containerView
	}
}
