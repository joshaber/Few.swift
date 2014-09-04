//
//  Input.swift
//  Few
//
//  Created by Josh Abernathy on 9/4/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import AppKit

public class Input<S>: Element {
	private var textField: NSTextField?
	
	private var text: String
	
	private let trampoline = TargetActionTrampoline()
	
	private weak var typedComponent: Component<S>?
	
	public convenience init(text: String, fn: (String, S) -> S) {
		self.init(text: text, action: { str, component in
			component.state = fn(str, component.state)
		})
	}

	public init(text: String, action: (String, Component<S>) -> ()) {
		self.text = text
		super.init()
		
		self.trampoline.action = { [unowned self] in
			self.text = self.textField!.stringValue
			if let component = self.typedComponent {
				action(self.text, component)
			}
		}
	}

	// MARK: Element
	
	public override func applyDiff(other: Element) {
		if textField == nil { return }
		
		let otherInput = other as Input
		if text != otherInput.text {
			text = otherInput.text
			textField!.stringValue = text
		}
		
		frame = CGRectZero
		
		super.applyDiff(other)
	}
	
	public override func realize(component: Component<S>, parentView: NSView) {
		let field = NSTextField(frame: frame)
		field.editable = true
//		field.drawsBackground = false
//		field.bordered = false
		field.stringValue = text
		field.target = trampoline
		field.action = trampoline.selector
		textField = field
		
		super.realize(component, parentView: parentView)
	}
	
	public override func getContentView() -> NSView? {
		return textField
	}
	
	public override func getIntrinsicSize() -> CGSize {
		var size = CGSizeZero
		if let textField = textField {
			let originalFrame = textField.frame
			textField.sizeToFit()
			size = textField.bounds.size
			textField.frame = originalFrame
		}
		return size
	}
}
