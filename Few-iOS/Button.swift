//
//  Button.swift
//  Few
//
//  Created by Coen Wessels on 13/03/15.
//  Copyright (c) 2015 Josh Abernathy. All rights reserved.
//

import UIKit

extension UIControlState: Hashable {
	static let all: [UIControlState] = [.Normal, .Selected, .Disabled, .Highlighted]
	public var hashValue: Int {
		return Int(rawValue)
	}
}

public class Button: Element {
	public var attributedTitles: [UIControlState: NSAttributedString]
	public var images: [UIControlState: UIImage]
	public var backgroundImages: [UIControlState: UIImage]
	public var enabled: Bool
	public var selected: Bool
	public var highlighted: Bool
	
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