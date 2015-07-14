//
//  Button.swift
//  Few
//
//  Created by Coen Wessels on 13/03/15.
//  Copyright (c) 2015 Josh Abernathy. All rights reserved.
//

import UIKit

public class Button: Element {
	public var attributedTitles: [UIControlState: NSAttributedString]
	public var images: [UIControlState: UIImage]
	public var backgroundImages: [UIControlState: UIImage]
	public var enabled: Bool
	public var selected: Bool
	public var highlighted: Bool
	
	private static let layoutButton = UIButton()
	
	private var trampoline = TargetActionTrampoline()

	public convenience init(attributedTitle: NSAttributedString = NSAttributedString(), image: UIImage? = nil, action: (() -> Void) = { }) {
		let images: [UIControlState: UIImage]
		if let image = image {
			images = [.Normal: image]
		} else {
			images = [:]
		}
		self.init(attributedTitles: [.Normal: attributedTitle], images: images, action: action)
	}
	
	public init(attributedTitles: [UIControlState: NSAttributedString] = [:], images: [UIControlState: UIImage] = [:], backgroundImages: [UIControlState: UIImage] = [:], enabled: Bool = true, selected: Bool = false, highlighted: Bool = false, action: (() -> Void) = { }) {
		self.images = images
		self.attributedTitles = attributedTitles
		self.backgroundImages = backgroundImages
		self.selected = selected
		self.enabled = enabled
		self.highlighted = highlighted
		trampoline.action = action
		super.init()
	}
	
	public var controlState: UIControlState {
		return UIControlState(enabled: enabled, selected: selected, highlighted: highlighted)
	}
	
	public override func assembleLayoutNode() -> Node {
		let childNodes = children.map { $0.assembleLayoutNode() }
		
		return Node(size: frame.size, children: childNodes, direction: direction, margin: marginWithPlatformSpecificAdjustments, padding: paddingWithPlatformSpecificAdjustments, wrap: wrap, justification: justification, selfAlignment: selfAlignment, childAlignment: childAlignment, flex: flex) { w in
			let controlState = self.controlState
			
			let layoutButton = Button.layoutButton
			layoutButton.enabled = self.enabled
			layoutButton.highlighted = self.highlighted
			layoutButton.selected = self.selected
			
			let attributedTitle = self.attributedTitles[controlState] ?? self.attributedTitles[.Normal]
			if layoutButton.attributedTitleForState(controlState) != attributedTitle {
				layoutButton.setAttributedTitle(attributedTitle, forState: controlState)
			}
			
			let image = self.images[controlState] ?? self.images[.Normal]
			if image != layoutButton.imageForState(controlState) {
				layoutButton.setImage(image, forState: controlState)
			}
			
			let fittingSize = CGSize(width: w.isNaN ? ABigDimension : w, height: ABigDimension)
			return layoutButton.sizeThatFits(fittingSize)
		}
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
				let image = images[state]
				if image != button.imageForState(state) {
					button.setImage(image, forState: state)
				}
				
				let title = attributedTitles[state]
				if title != button.attributedTitleForState(state) {
					button.setAttributedTitle(title, forState: state)
				}
				
				let bg = backgroundImages[state]
				if bg != button.backgroundImageForState(state) {
					button.setBackgroundImage(bg, forState: state)
				}
			}
		}
	}
	
	public override func createView() -> ViewType {
		let button = UIButton()
		for (state, image) in images {
			button.setImage(image, forState: state)
		}
		for (state, title) in attributedTitles {
			button.setAttributedTitle(title, forState: state)
		}
		for (state, backgroundImage) in backgroundImages {
			button.setBackgroundImage(backgroundImage, forState: state)
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