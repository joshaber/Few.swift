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
private let StringFudge = CGSize(width: 4, height: 0)

private let ABigDimension: CGFloat = 10000

internal func estimateStringSize(string: NSAttributedString, maxSize: CGSize = CGSize(width: ABigDimension, height: ABigDimension)) -> CGSize {
	let rect = string.boundingRectWithSize(maxSize, options: .UsesLineFragmentOrigin | .UsesFontLeading)
	let width = ceil(rect.size.width) + StringFudge.width
	let height = ceil(rect.size.height) + StringFudge.height
	return CGSize(width: width, height: height)
}

public class Label: Element {
	private var attributedString: NSAttributedString

	public var text: String { return attributedString.string }

	public convenience init(_ text: String, textColor: NSColor = .controlTextColor(), font: NSFont = DefaultLabelFont) {
		let attributes = [
			NSFontAttributeName: font,
			NSForegroundColorAttributeName: textColor,
		]
		self.init(attributedString: NSAttributedString(string: text, attributes: attributes))
	}

	public init(attributedString: NSAttributedString) {
		self.attributedString = attributedString
	}

	// MARK: Element

	public override func applyDiff(old: Element, realizedSelf: RealizedElement?) {
		super.applyDiff(old, realizedSelf: realizedSelf)

		if let textField = realizedSelf?.view as? NSTextField {
			if attributedString != textField.attributedStringValue {
				textField.attributedStringValue = attributedString
				realizedSelf?.markNeedsLayout()
			}
		}
	}

	public override func createView() -> ViewType {
		let field = NSTextField(frame: CGRectZero)
		field.editable = false
		field.drawsBackground = false
		field.bordered = false
		field.font = DefaultLabelFont
		field.attributedStringValue = attributedString
		field.alphaValue = alpha
		field.hidden = hidden
		return field
	}

	public override func assembleLayoutNode() -> Node {
		let childNodes = children.map { $0.assembleLayoutNode() }
		return Node(size: frame.size, children: childNodes, direction: direction, margin: marginWithPlatformSpecificAdjustments, padding: paddingWithPlatformSpecificAdjustments, wrap: wrap, justification: justification, selfAlignment: selfAlignment, childAlignment: childAlignment, flex: flex) { w in
			estimateStringSize(self.attributedString, maxSize: CGSize(width: w.isNaN ? ABigDimension : w, height: ABigDimension))
		}
	}
}
