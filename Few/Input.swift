//
//  Input.swift
//  Few
//
//  Created by Josh Abernathy on 8/1/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import AppKit

public class Input<S: Equatable>: Element<S> {
	private var textField: NSTextField?

	public override init() {}

	public override func applyDiff(other: Element<S>) {
		if textField == nil { return }
	}

	public override func realize(component: Component<S>, parentView: NSView) {
		textField = NSTextField(frame: NSRect(x: 0, y: 0, width: 100, height: 100))

		super.realize(component, parentView: parentView)
	}

	public override func getContentView() -> NSView? {
		return textField
	}
}