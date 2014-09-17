//
//  WrappedView.swift
//  Few
//
//  Created by Josh Abernathy on 9/16/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import AppKit

public class WrappedView<T: NSView>: Element {
	private var type: T.Type
	private var config: T -> ()
	private var view: T?
	
	public init(type: T.Type, config: T -> ()) {
		self.type = type
		self.config = config
	}
	
	// MARK: Element
	
	public override func canDiff(other: Element) -> Bool {
		if !super.canDiff(other) { return false }
		
		let otherWrapped = other as WrappedView
		return type === otherWrapped.type
	}
	
	// `component` should be Component<S>, but if we do then Xcode think it's 
	// not overriding `realize`, so.
	public override func realize<S>(component: Element, parentView: NSView) {
		let view = type()
		config(view)
		
		self.view = view

		let opaqueComponent = Unmanaged.passRetained(component).toOpaque()
		let castComponent: Component<S> = Unmanaged.fromOpaque(opaqueComponent).takeRetainedValue()
		super.realize(castComponent, parentView: parentView)
	}

	public override func applyDiff(other: Element) {
		let otherWrapped = other as WrappedView
		
		config = otherWrapped.config
		if let view = view {
			config(view)
		}
	}

	public override func getContentView() -> NSView? {
		return view
	}
	
}
