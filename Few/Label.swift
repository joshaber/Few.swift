//
//  Label.swift
//  Few
//
//  Created by Josh Abernathy on 8/5/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import AppKit

public class Label: Element {
	private let text: String

	public init(text: String) {
		self.text = text
	}

	// MARK: Element

	public override func applyDiff(view: ViewType, other: Element) {
		let otherLabel = other as Label
		let textField = view as NSTextField

		if text != textField.stringValue {
			textField.stringValue = text
		}

		super.applyDiff(view, other: other)
	}

	public override func realize() -> ViewType? {
		let field = NSTextField(frame: frame)
		field.editable = false
		field.drawsBackground = false
		field.bordered = false
		field.stringValue = text
		return field
	}
}
