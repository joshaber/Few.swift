//
//  Label.swift
//  Few
//
//  Created by Coen Wessels on 13/03/15.
//  Copyright (c) 2015 Josh Abernathy. All rights reserved.
//

import UIKit

private let DefaultLabelFont = UIFont.systemFontOfSize(UIFont.systemFontSize())

private let ABigDimension: CGFloat = 10000

private let sizingLabel = UILabel()

internal func estimateStringSize(string: NSAttributedString, maxSize: CGSize = CGSize(width: ABigDimension, height: ABigDimension), numberOfLines: Int) -> CGSize {
	sizingLabel.attributedText = string
	sizingLabel.numberOfLines = numberOfLines
	return sizingLabel.sizeThatFits(maxSize)
}

public class Label: Element {
	public var attributedString: NSAttributedString
	
	/// Same behavior as UILabel, also defaults to 1.
	public var numberOfLines: Int
	
	public var text: String { return attributedString.string }

	public convenience init(_ text: String, textColor: UIColor = .blackColor(), font: UIFont = DefaultLabelFont, numberOfLines: Int = 1) {
		let attributes = [
			NSFontAttributeName: font,
			NSForegroundColorAttributeName: textColor,
		]
		self.init(attributedString: NSAttributedString(string: text, attributes: attributes), numberOfLines: numberOfLines)
	}

	public init(attributedString: NSAttributedString, numberOfLines: Int = 1) {
		self.attributedString = attributedString
		self.numberOfLines = numberOfLines
	}

	// MARK: Element

	public override func applyDiff(old: Element, realizedSelf: RealizedElement?) {
		super.applyDiff(old, realizedSelf: realizedSelf)

		if let realizedSelf = realizedSelf, label = realizedSelf.view as? UILabel {
			
			if attributedString != label.attributedText {
				label.attributedText = attributedString
				realizedSelf.markNeedsLayout()
			}
			
			if numberOfLines != label.numberOfLines {
				label.numberOfLines = numberOfLines
				realizedSelf.markNeedsLayout()
			}
		}
	}

	public override func createView() -> ViewType {
		let label = UILabel(frame: CGRectZero)
		label.numberOfLines = numberOfLines
		label.font = DefaultLabelFont
		label.attributedText = attributedString
		label.alpha = alpha
		label.hidden = hidden
		return label
	}

	public override func assembleLayoutNode() -> Node {
		let childNodes = children.map { $0.assembleLayoutNode() }
		return Node(size: frame.size, children: childNodes, direction: direction, margin: marginWithPlatformSpecificAdjustments, padding: paddingWithPlatformSpecificAdjustments, wrap: wrap, justification: justification, selfAlignment: selfAlignment, childAlignment: childAlignment, flex: flex) { w in
			estimateStringSize(self.attributedString, maxSize: CGSize(width: w.isNaN ? ABigDimension : w, height: ABigDimension), self.numberOfLines)
		}
	}
}
