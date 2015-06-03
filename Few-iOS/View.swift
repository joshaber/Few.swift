//
//  View.swift
//  Few
//
//  Created by Coen Wessels on 13/03/15.
//  Copyright (c) 2015 Josh Abernathy. All rights reserved.
//

import UIKit

public class View: Element {
	public var backgroundColor: UIColor?
	public var borderColor: UIColor?
	public var borderWidth: CGFloat
	public var cornerRadius: CGFloat
	
	public init(backgroundColor: UIColor? = nil, borderColor: UIColor? = nil, borderWidth: CGFloat = 0, cornerRadius: CGFloat = 0) {
		self.backgroundColor = backgroundColor
		self.borderColor = borderColor
		self.borderWidth = borderWidth
		self.cornerRadius = cornerRadius
	}
	
	// MARK: Element
	
	public override func applyDiff(old: Element, realizedSelf: RealizedElement?) {
		super.applyDiff(old, realizedSelf: realizedSelf)
		
		if let backgroundView = realizedSelf?.view {
			if backgroundColor !== backgroundView.backgroundColor {
				backgroundView.backgroundColor = backgroundColor
			}
			
			if backgroundView.layer.borderColor != nil {
				let backgroundViewBorderColor = UIColor(CGColor: backgroundView.layer.borderColor)
				if borderColor != backgroundViewBorderColor {
					backgroundView.layer.borderColor = borderColor?.CGColor
				}
			}
			
			if borderWidth != backgroundView.layer.borderWidth {
				backgroundView.layer.borderWidth = borderWidth
			}
			
			if cornerRadius != backgroundView.layer.cornerRadius {
				backgroundView.layer.cornerRadius = cornerRadius
			}
		}
	}
	
	public override func createView() -> ViewType {
		let view = UIView(frame: CGRectZero)
		view.alpha = alpha
		view.hidden = hidden
		view.backgroundColor = backgroundColor
		if let borderColor = borderColor?.CGColor {
			view.layer.borderColor = borderColor
		}
		view.layer.borderWidth = borderWidth
		view.layer.cornerRadius = cornerRadius
		return view
	}
}