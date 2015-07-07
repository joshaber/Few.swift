//
//  Button.swift
//  Few
//
//  Created by Coen Wessels on 13/03/15.
//  Copyright (c) 2015 Josh Abernathy. All rights reserved.
//

import UIKit

public class Button: Element {
	public var title: NSAttributedString
	public var enabled: Bool
	
	private var trampoline = TargetActionTrampoline()
	
	public init(title: String, enabled: Bool = true, action: () -> () = { }) {
		self.title = NSAttributedString(string: title)
		self.enabled = enabled
		trampoline.action = action
		super.init(frame: CGRect(x: 0, y: 0, width: 50, height: 23))
	}
	
	// MARK: Element
	
	public override func applyDiff(old: Element, realizedSelf: RealizedElement?) {
		super.applyDiff(old, realizedSelf: realizedSelf)
		
		if let button = realizedSelf?.view as? UIButton {
			if let oldButton = old as? Button {
				let newTrampoline = oldButton.trampoline
				newTrampoline.action = trampoline.action // Make sure the newest action is used
				trampoline = newTrampoline
			}
			
			if title != button.titleLabel?.attributedText {
				button.setAttributedTitle(title, forState: .Normal)
			}
			
			if enabled != button.enabled {
				button.enabled = enabled
			}
		}
	}
	
	public override func createView() -> ViewType {
		let button = UIButton(frame: CGRectZero)
		button.alpha = alpha
		button.hidden = hidden
		button.setAttributedTitle(title, forState: .Normal)
		button.setTitleColor(UIColor.blackColor(), forState: .Normal)
		button.enabled = enabled
		button.addTarget(trampoline, action: trampoline.selector, forControlEvents: .TouchUpInside)
		return button
	}
}