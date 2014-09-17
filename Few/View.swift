//
//  View.swift
//  Few
//
//  Created by Josh Abernathy on 9/16/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import AppKit

public class View<T: NSView>: Element {
	private var constructor: () -> T
	private var config: T -> ()
	private var view: T?
	
	public init(constructor: () -> T, config: T -> ()) {
		self.constructor = constructor
		self.config = config
	}
	
	// MARK: Element
	
	// `component` should be Component<S>, but if we do then Xcode think it's 
	// not overriding `realize`, so.
	public override func realize<S>(component: Element, parentView: NSView) {
		let view = constructor()
		config(view)
		
		self.view = view

		let opaqueComponent = Unmanaged.passRetained(component).toOpaque()
		let castComponent: Component<S> = Unmanaged.fromOpaque(opaqueComponent).takeRetainedValue()
		super.realize(castComponent, parentView: parentView)
	}

	public override func applyDiff(other: Element) {
		let otherView = other as View
		
		config = otherView.config
		if let view = view {
			config(view)
		} else {
			constructor = otherView.constructor
		}
	}

	public override func getContentView() -> NSView? {
		return view
	}
	
}
