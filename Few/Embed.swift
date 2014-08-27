//
//  Embed.swift
//  Few
//
//  Created by Josh Abernathy on 8/23/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import AppKit

public class Embed<S>: Element {
	private var containedComponent: Component<S>
	
	public init(_ component: Component<S>) {
		containedComponent = component
	}
	
	// MARK: Element
	
	public override func applyLayout(fn: Element -> CGRect) {
		// TODO: It'd be nice if this worked?
	}

	public override func canDiff(other: Element) -> Bool {
		if !super.canDiff(other) { return false }
		
		let otherEmbed = other as Embed
		return containedComponent === otherEmbed.containedComponent
	}

	public override func applyDiff(other: Element) {
		// This is pretty meaningless since we check for pointer equality in 
		// canDiff.
	}
	
	public override func realize(component: Component<S>, parentView: NSView) {
		containedComponent.addToView(parentView)
	}
	
	public override func derealize() {
		getContentView()?.removeFromSuperview()
	}
	
	public override func getContentView() -> NSView? {
		return containedComponent.getContentView()
	}
	
	public override func getIntrinsicSize() -> CGSize {
		return containedComponent.getIntrinsicSize()
	}
}
