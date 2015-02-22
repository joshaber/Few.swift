//
//  Label.swift
//  Few
//
//  Created by Josh Abernathy on 8/5/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import AppKit

private let DefaultLabelFont = NSFont.labelFontOfSize(NSFont.systemFontSizeForControlSize(.RegularControlSize))
private let LabelFudge = CGSize(width: 4, height: 0)

public class Label: Element {
	private var attributedString: NSAttributedString

	public var text: String { return attributedString.string }

	public convenience init(text: String, textColor: NSColor = .controlTextColor(), font: NSFont = DefaultLabelFont) {
		let attributes = [
			NSFontAttributeName: font,
			NSForegroundColorAttributeName: textColor,
		]
		self.init(attributedString: NSAttributedString(string: text, attributes: attributes))
	}

	public init(attributedString: NSAttributedString) {
		self.attributedString = attributedString

		let capSize = CGSize(width: 1000, height: 1000)
		let rect = self.attributedString.boundingRectWithSize(capSize, options: .UsesLineFragmentOrigin | .UsesFontLeading)
		let width = ceil(rect.size.width) + LabelFudge.width
		let height = ceil(rect.size.height) + LabelFudge.height
		super.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
	}

	// MARK: Element

	public override func applyDiff(old: Element, realizedSelf: RealizedElement?) {
		super.applyDiff(old, realizedSelf: realizedSelf)

		if let textField = realizedSelf?.view as? NSTextField {
			if attributedString != textField.attributedStringValue {
				textField.attributedStringValue = attributedString
			}
		}
	}

	public override func createView() -> ViewType {
		let field = NSTextField(frame: frame)
		field.editable = false
		field.drawsBackground = false
		field.bordered = false
		field.font = DefaultLabelFont
		field.attributedStringValue = attributedString
		return field
	}
}
