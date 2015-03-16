//
//  Label.swift
//  Few
//
//  Created by Coen Wessels on 13/03/15.
//  Copyright (c) 2015 Josh Abernathy. All rights reserved.
//

import UIKit

private let DefaultLabelFont = UIFont.systemFontOfSize(UIFont.systemFontSize())
private let StringFudge = CGSize(width: 4, height: 0)

private let ABigDimension: CGFloat = 10000

internal func estimateStringSize(string: NSAttributedString, maxSize: CGSize = CGSize(width: ABigDimension, height: ABigDimension)) -> CGSize {
    let options: NSStringDrawingOptions = NSStringDrawingOptions.UsesLineFragmentOrigin// | NSStringDrawingOptions.UsesFontLeading // Currently this is an enum(so it does not support multiple values). But this is fixed in iOS 8.3 SDK Beta 1
    let rect = string.boundingRectWithSize(maxSize, options: options, context: nil)
    let width = ceil(rect.size.width) + StringFudge.width
    let height = ceil(rect.size.height) + StringFudge.height
    return CGSize(width: width, height: height)
}

public class Label: Element {
    private var attributedString: NSAttributedString
    
    public var text: String { return attributedString.string }
    
    public convenience init(_ text: String, textColor: UIColor = .blackColor(), font: UIFont = DefaultLabelFont) {
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
        
        if let label = realizedSelf?.view as? UILabel {
            if attributedString != label.attributedText {
                label.attributedText = attributedString
            }
        }
    }
    
    public override func createView() -> ViewType {
        let field = UILabel(frame: frame)
        field.font = DefaultLabelFont
        field.attributedText = attributedString
        field.alpha = alpha
        field.hidden = hidden
        return field
    }
    
    internal override func assembleLayoutNode() -> Node {
        let childNodes = children.map { $0.assembleLayoutNode() }
        return Node(size: frame.size, children: childNodes, direction: direction, margin: margin, padding: padding, wrap: wrap, justification: justification, selfAlignment: selfAlignment, childAlignment: childAlignment, flex: flex) { w in
            estimateStringSize(self.attributedString, maxSize: CGSize(width: w.isNaN ? ABigDimension : w, height: ABigDimension))
        }
    }
}