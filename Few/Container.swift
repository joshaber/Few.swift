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
		super.init()
	}

	public required init(arrayLiteral elements: Element...) {
		self.children = elements
		super.init()
	}

	public required init(copy: Element, frame: CGRect, hidden: Bool, key: String?, alpha: CGFloat) {
		let container = copy as Container
		children = container.children
		super.init(copy: copy, frame: frame, hidden: hidden, key: key, alpha: alpha)
	}

	// MARK: Element

	public override func realize() -> ViewType? {
		return ViewType(frame: frame)
	}

	public override func getChildren() -> [Element] {
		return children
	}
}
