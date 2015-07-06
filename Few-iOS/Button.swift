//
//  Button.swift
//  Few
//
//  Created by Coen Wessels on 13/03/15.
//  Copyright (c) 2015 Josh Abernathy. All rights reserved.
//

import UIKit

private extension UIControlState {
	static let all: [UIControlState] = [.Normal, .Selected, .Disabled, .Highlighted]
}

public class Button: Element {
	public var attributedTitleForState: (UIControlState -> NSAttributedString?)
	public var imageForState: (UIControlState -> UIImage?)
	public var backgroundImageForState: (UIControlState -> UIImage?)
	public var enabled: Bool
	public var selected: Bool
	public var highlighted: Bool
	
	private var trampoline = TargetActionTrampoline()

	public convenience init(attributedTitle: NSAttributedString, image: UIImage? = nil, action: (() -> Void) = { }) {
		self.init(attributedTitleForState: {_ in attributedTitle}, imageForState: {_ in image}, action: {_ in action() })
	}
	
	public init(attributedTitleForState: (UIControlState -> NSAttributedString?), imageForState: (UIControlState -> UIImage?) = {_ in nil}, backgroundImageForState: (UIControlState -> UIImage?) = {_ in nil}, enabled: Bool = true, selected: Bool = false, highlighted: Bool = false, action: (() -> Void) = { }) {
		self.imageForState = imageForState
		self.attributedTitleForState = attributedTitleForState
		self.backgroundImageForState = backgroundImageForState
		self.selected = selected
		self.enabled = enabled
		self.highlighted = highlighted
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
			
			if enabled != button.enabled {
				button.enabled = enabled
			}
			
			if selected != button.selected {
				button.selected = selected
			}

			if highlighted != button.highlighted {
				button.highlighted = highlighted
			}
			
			for state in UIControlState.all {
				let newImage = imageForState(state)
				if button.imageForState(state) != newImage {
					button.setImage(newImage, forState: state)
				}
				
				let newBG = backgroundImageForState(state)
				if button.backgroundImageForState(state) != newBG {
					button.setBackgroundImage(newBG, forState: state)
				}
				
				let newTitle = attributedTitleForState(state)
				if button.attributedTitleForState(state) != newTitle {
					button.setAttributedTitle(newTitle, forState: state)
				}
			}
		}
	}
	
	public override func createView() -> ViewType {
		let button = UIButton()
		for state in UIControlState.all {
			button.setAttributedTitle(attributedTitleForState(state), forState: state)
			button.setImage(imageForState(state), forState: state)
			button.setBackgroundImage(backgroundImageForState(state), forState: state)
		}
		button.alpha = alpha
		button.hidden = hidden
		button.enabled = enabled
		button.selected = selected
		button.highlighted = highlighted
		button.addTarget(trampoline, action: trampoline.selector, forControlEvents: .TouchUpInside)
		return button
	}
}