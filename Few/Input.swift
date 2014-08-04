//
//  Input.swift
//  Few
//
//  Created by Josh Abernathy on 8/1/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import AppKit

public class Input<S: Equatable, T: Setable where T.ValueType == S>: Element<S, T> {
	private var textField: NSTextField?

	public init() {}

	public override func applyDiff(other: Element<S, T>) {
		if !textField.getLogicValue() {
			return
		}
	}

	public override func realize(parentView: NSView, setable: T) {
		textField = NSTextField(frame: NSRect(x: 0, y: 0, width: 100, height: 100))

		super.realize(parentView, setable: setable)
	}

	public override func getContentView() -> NSView? {
		return textField
	}
}