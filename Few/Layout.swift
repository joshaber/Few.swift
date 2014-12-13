//
//  Layout.swift
//  Few
//
//  Created by Josh Abernathy on 12/3/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import LlamaKit
import Cartography

public func leftAlign(x: CGFloat)(elements: [Element]) -> [Element] {
	for element in elements {
		element.frame.origin.x = x
	}
	
	return elements
}

public func verticalStack(top: CGFloat, padding: CGFloat)(elements: [Element]) -> [Element] {
	var y = top
	for element in elements {
		if element.hidden { continue }

		y -= element.frame.size.height + padding
		element.frame.origin.y = y
	}

	return elements
}

public func horizontalStack(left: CGFloat, padding: CGFloat)(elements: [Element]) -> [Element] {
	var x = left
	for element in elements {
		if element.hidden { continue }

		x += element.frame.size.width + padding
		element.frame.origin.x = x
	}

	return elements
}

public func offset(x: CGFloat, y: CGFloat)(elements: [Element]) -> [Element] {
	for element in elements {
		element.frame.origin.x += x
		element.frame.origin.y += y
	}

	return elements
}
