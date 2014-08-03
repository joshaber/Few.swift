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

	public init() {}

	public override func applyDiff(other: Element<S>) {
		if !textField.getLogicValue() {
			return
		}
	}

	public override func realize(parentView: NSView) {
		textField = NSTextField(frame: NSRect(x: 0, y: 0, width: 100, height: 100))

		super.realize(parentView)
	}

	public override func getContentView() -> NSView? {
		return textField
	}
}