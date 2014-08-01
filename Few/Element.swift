//
//  Element.swift
//  Few
//
//  Created by Josh Abernathy on 7/22/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import AppKit

public class Element<S: Equatable> {
	public func canDiff(other: Element<S>) -> Bool {
		return other.dynamicType === self.dynamicType
	}

	public func applyDiff(other: Element<S>) {
		
	}

	public func realize(parentView: NSView) {
		if let contentView = getContentView() {
			parentView.addSubview(contentView)
		}
	}

	public func derealize() {
		if let contentView = getContentView() {
			contentView.removeFromSuperview()
		}
	}

	public func getContentView() -> NSView? {
		return nil
	}
}
