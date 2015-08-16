//
//  Layout.swift
//  SwiftBox
//
//  Created by Josh Abernathy on 1/30/15.
//  Copyright (c) 2015 Josh Abernathy. All rights reserved.
//

import Foundation

/// An evaluated layout.
/// 
/// Layouts may not be created manually. They only ever come from laying out a 
/// Node. See Node.layout.
public struct Layout {
	public let frame: CGRect
	public let children: [Layout]

	internal init(frame: CGRect, children: [Layout]) {
		self.frame = frame
		self.children = children
	}
}

extension Layout: CustomStringConvertible {
	public var description: String {
		return descriptionForDepth(0)
	}

	private func descriptionForDepth(depth: Int) -> String {
		let selfDescription = "{origin={\(frame.origin.x), \(frame.origin.y)}, size={\(frame.size.width), \(frame.size.height)}}"
		if children.count > 0 {
			let indentation = (0...depth).reduce("\n") { accum, _ in accum + "\t" }
			let childrenDescription = indentation.join(children.map { $0.descriptionForDepth(depth + 1) })
			return "\(selfDescription)\(indentation)\(childrenDescription)"
		} else {
			return selfDescription
		}
	}
}
