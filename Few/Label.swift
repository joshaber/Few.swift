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
	private var textField: NSTextField?

	private var text: String

	public init(text: String) {
		self.text = text
	}

	// MARK: Element

	public override func applyDiff(other: Element) {
		let otherLabel = other as Label
		textField = otherLabel.textField

		if text != otherLabel.text {
			textField?.stringValue = text
		}

		super.applyDiff(other)
	}

	public override func realize<S>(component: Component<S>, parentView: ViewType) {
		let field = NSTextField(frame: frame)
		field.editable = false
		field.drawsBackground = false
		field.bordered = false
		field.stringValue = text
		textField = field

		super.realize(component, parentView: parentView)
	}

	public override func getContentView() -> ViewType? {
		return textField
	}
}
