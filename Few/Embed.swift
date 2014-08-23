//
//  Embed.swift
//  Few
//
//  Created by Josh Abernathy on 8/23/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import AppKit

public class Embed<S, T>: Element<S> {
	private var component: Component<T>
	
	public init(_ component: Component<T>) {
		self.component = component
	}
	
	// MARK: Element
	
	public override func applyLayout(fn: Element<S> -> CGRect) {
		// TODO: It'd be nice if this worked?
	}

	public override func canDiff(other: Element<S>) -> Bool {
		if !super.canDiff(other) { return false }
		
		let otherEmbed = other as Embed
		return component === otherEmbed.component
	}

	public override func applyDiff(other: Element<S>) {
		// This is pretty meaningless since we check for pointer equality in 
		// canDiff.
	}
	
	public override func realize(component: Component<S>, parentView: NSView) {
		self.component.addToView(parentView)
	}
	
	public override func derealize() {
		getContentView()?.removeFromSuperview()
	}
	
	public override func getContentView() -> NSView? {
		return component.getContentView()
	}
	
	public override func getIntrinsicSize() -> CGSize {
		return component.getIntrinsicSize()
	}
}
