//
//  View.swift
//  Few
//
//  Created by Josh Abernathy on 8/27/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import AppKit

/// An Element which acts as a dumb container for a view. It doesn't do any 
/// diffing.
public class View<V: NSView>: Element {
	public let view: V
	
	public init(_ view: V) {
		self.view = view
	}
	
	// MARK: Element
	
	public override func canDiff(other: Element) -> Bool {
		if !super.canDiff(other) { return false }
		
		let otherView = other as View
		return view === otherView.view
	}
	
	public override func applyDiff(other: Element) {
		// Nope. We're just wrapping a view.
	}
	
	/// Get the content view which represents the element.
	public override func getContentView() -> NSView? {
		return view
	}
	
	public override func getIntrinsicSize() -> CGSize {
		return view.intrinsicContentSize
	}
}
