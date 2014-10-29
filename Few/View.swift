//
//  View.swift
//  Few
//
//  Created by Josh Abernathy on 9/16/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import AppKit

/// A Element-wrapped view.
public class View<T: ViewType>: Element {
	private let type: T.Type

	private var config: T -> ()

	public init(type: T.Type, config: T -> ()) {
		self.type = type
		self.config = config
	}
	
	// MARK: Element
	
	public override func canDiff(other: Element) -> Bool {
		if !super.canDiff(other) { return false }
		
		let otherView = other as View
		return type === otherView.type
	}

	public override func applyDiff(view: ViewType, other: Element) {
		let otherView = view as T

		config(otherView)

		super.applyDiff(view, other: other)
	}

	public override func realize() -> ViewType? {
		let view = type()
		config(view)
		
		return view
	}
}
