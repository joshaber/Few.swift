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
	
	// MARK: Element

	public override func applyDiff(other: Element) {
		let otherContainer = other as Container
		var newChildren = Array<Element>()
		for (myChild, theirChild) in Zip2(children, otherContainer.children) {
			if myChild.canDiff(theirChild) {
				myChild.applyDiff(theirChild)
				newChildren.append(myChild)
			} else {
				myChild.derealize()
				curry(theirChild.realize) <^> component <*> containerView
				newChildren.append(theirChild)
			}
		}
		
		children = newChildren
		
		super.applyDiff(other)
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
