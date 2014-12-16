//
//  Layout.swift
//  Few
//
//  Created by Josh Abernathy on 12/3/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation

extension Array {
	func mapWithState<S>(initial: S, fn: (S, T) -> (S, T)) -> [T] {
		var newArray: [T] = []
		var currentState = initial
		for element in self {
			let (newState, newElement) = fn(currentState, element)
			newArray.append(newElement)
			currentState = newState
		}

		return newArray
	}
}

public func leftAlign(x: CGFloat)(elements: [Element]) -> [Element] {
	return elements.map { el in el.x(x) }
}

public func verticalStack(top: CGFloat, padding: CGFloat)(elements: [Element]) -> [Element] {
	return elements
		.filter { !$0.hidden }
		.mapWithState(top) { currentY, el in
			let y = currentY - (el.frame.size.height + padding)
			let newElement = el.y(y)
			return (y, newElement)
		}
}

public func horizontalStack(left: CGFloat, padding: CGFloat)(elements: [Element]) -> [Element] {
	return elements
		.filter { !$0.hidden }
		.mapWithState(left) { currentX, el in
			let x = currentX + el.frame.size.width + padding
			let newElement = el.x(x)
			return (x, newElement)
		}
}

public func offset(x: CGFloat, y: CGFloat)(elements: [Element]) -> [Element] {
	return elements.map { el in el.frame(CGRectOffset(el.frame, x, y)) }
}
