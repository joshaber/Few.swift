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
	private var view: T?
	
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

	public override func applyDiff(other: Element) {
		let otherView = other as View
		view = otherView.view

		config <^> view

		super.applyDiff(other)
	}

	public override func realize(parentView: ViewType) {
		let view = type()
		config(view)
		
		self.view = view

		super.realize(parentView)
	}

	public override func getContentView() -> ViewType? {
		return view
	}
	
}
