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

	public convenience init(_ child: Element...) {
		self.init(child)
	}
	
	// MARK: Element

	public override func applyDiff(other: Element) {
		let otherContainer = other as Container
		var newChildren = Array<Element>()
		let myChildCount = children.count
		let theirChildCount = otherContainer.children.count
		for i in 0..<max(myChildCount, theirChildCount) {
			var myChild: Element?
			if i < myChildCount {
				myChild = children[i]
			}

			var theirChild: Element?
			if i < theirChildCount {
				theirChild = otherContainer.children[i]
			}

			if myChild != nil && theirChild != nil {
				if myChild!.canDiff(theirChild!) {
					myChild!.applyDiff(theirChild!)
					newChildren.append(myChild!)
				} else {
					myChild!.derealize()

					let component: Component<Any>? = getComponent()
					curry(theirChild!.realize) <^> component <*> containerView
					newChildren.append(theirChild!)
				}
			} else if let myChild = myChild {
				myChild.derealize()
			} else if let theirChild = theirChild {
				let component: Component<Any>? = getComponent()
				curry(theirChild.realize) <^> component <*> containerView
				newChildren.append(theirChild)
			}

			children = newChildren

			super.applyDiff(other)
		}
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

//extension Container: ArrayLiteralConvertible {
//	public class func convertFromArrayLiteral(elements: Element...) -> Self {
//		return Container(elements)
//	}
//}
