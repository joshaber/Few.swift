//
//  Label.swift
//  Few
//
//  Created by Josh Abernathy on 8/5/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import AppKit

public class Label<S: Equatable>: Element<S> {
	private var textField: NSTextField?

	private var text: String
	public var frame = CGRectZero

	public init(text: String) {
		self.text = text
	}

	// MARK: Element

	public override func applyDiff(other: Element<S>) {
		if textField == nil { return }

		let otherLabel = other as Label
		if text != otherLabel.text {
			text = otherLabel.text
			textField!.stringValue = text
		}

		if frame != otherLabel.frame {
			frame = otherLabel.frame
			textField!.frame = frame
		}

		textField!.sizeToFit()
	}

	public override func realize(component: Component<S>, parentView: NSView) {
		textField = NSTextField(frame: frame)
		textField!.editable = false
		textField!.drawsBackground = false
		textField!.bordered = false
		textField!.stringValue = text

		super.realize(component, parentView: parentView)
	}

	public override func getContentView() -> NSView? {
		return textField
	}
}

extension Label: Frameable {}
