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
	private let attributedString: NSAttributedString

	public convenience init(text: String) {
		let attributedString = NSAttributedString(string: text, attributes: [NSFontAttributeName: DefaultLabelFont])
		self.init(attributedString: attributedString)
	}

	public init(attributedString: NSAttributedString) {
		self.attributedString = attributedString

		let capSize = CGSize(width: 1000, height: 1000)
		let rect = self.attributedString.boundingRectWithSize(capSize, options: .UsesLineFragmentOrigin | .UsesFontLeading)
		let width = ceil(rect.size.width) + LabelFudge.width
		let height = ceil(rect.size.height) + LabelFudge.height
		super.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
	}

	public required init(copy: Element, frame: CGRect, hidden: Bool, key: String?) {
		let label = copy as Label
		attributedString = label.attributedString
		super.init(copy: copy, frame: frame, hidden: hidden, key: key)
	}

	// MARK: Element

	public override func applyDiff(view: ViewType, other: Element) {
		let otherLabel = other as Label
		let textField = view as NSTextField

		if attributedString != textField.attributedStringValue {
			textField.attributedStringValue = attributedString
		}

		super.applyDiff(view, other: other)
	}

	public override func realize() -> ViewType? {
		let field = NSTextField(frame: frame)
		field.editable = false
		field.drawsBackground = false
		field.bordered = false
		field.font = DefaultLabelFont
		field.attributedStringValue = attributedString
		return field
	}
}
