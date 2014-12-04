//
//  Container.swift
//  Few
//
//  Created by Josh Abernathy on 8/27/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import AppKit

/// Containers (surprise!) contain other elements.
public class Container: Element, ArrayLiteralConvertible {
	private let children: [Element]

	public init(_ children: [Element]) {
		self.children = children
	}

	public required init(arrayLiteral elements: Element...) {
		self.children = elements
	}

	// MARK: Element

	public override func realize() -> ViewType? {
		return NSView(frame: frame)
	}

	public override func getChildren() -> [Element] {
		return children
	}
}
