//
//  Input.swift
//  Few
//
//  Created by Coen Wessels on 14-03-15.
//  Copyright (c) 2015 Josh Abernathy. All rights reserved.
//

import UIKit

final internal class InputDelegate: NSObject, UITextFieldDelegate {
	var shouldReturn: (UITextField -> Bool)?
	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		return shouldReturn?(textField) ?? true
	}
}

public class Input: Element {
	public var text: String?
	public var textColor: UIColor?
	public var font: UIFont?
	public var initialText: String?
	public var placeholder: String?
	public var enabled: Bool
	public var secure: Bool
	public var borderStyle: UITextBorderStyle
	public var keyboardType: UIKeyboardType
	public var returnKeyType: UIReturnKeyType
	public var autocorrectionType: UITextAutocorrectionType
	public var autocapitalizationType: UITextAutocapitalizationType
	
	private var actionTrampoline = TargetActionTrampolineWithSender<UITextField>()
	private var inputDelegate = InputDelegate()
	
	public init(text: String? = nil, textColor: UIColor? = nil, font: UIFont? = nil, initialText: String? = nil, placeholder: String? = nil, enabled: Bool = true, secure: Bool = false, borderStyle: UITextBorderStyle = .None, keyboardType: UIKeyboardType = .Default, returnKeyType: UIReturnKeyType = .Default, autocorrectionType: UITextAutocorrectionType = .Default, autocapitalizationType: UITextAutocapitalizationType = .Sentences, shouldReturn: String -> Bool = { _ in true }, textChanged: String -> () = { _ in }) {
		self.text = text
		self.textColor = textColor
		self.font = font
		self.initialText = initialText
		self.placeholder = placeholder
		self.enabled = enabled
		self.secure = secure
		self.borderStyle = borderStyle
		self.keyboardType = keyboardType
		self.returnKeyType = returnKeyType
		self.autocorrectionType = autocorrectionType
		self.autocapitalizationType = autocapitalizationType
		actionTrampoline.action = { textField in
			textChanged(textField.text)
		}
		inputDelegate.shouldReturn = { textField in
			shouldReturn(textField.text)
		}
		
		super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 23))
	}
	
	// MARK: Element
	
	public override func applyDiff(old: Element, realizedSelf: RealizedElement?) {
		super.applyDiff(old, realizedSelf: realizedSelf)
		
		if let textField = realizedSelf?.view as? UITextField {
			if let oldInput = old as? Input {
				let newTrampoline = oldInput.actionTrampoline
				newTrampoline.action = actionTrampoline.action // Make sure the newest action is used
				actionTrampoline = newTrampoline
			}
			
			textField.delegate = inputDelegate
			
			if placeholder != textField.placeholder {
				textField.placeholder = placeholder
			}
			
			if let text = text where text != textField.text {
				textField.text = text
			}
			
			if enabled != textField.enabled {
				textField.enabled = enabled
			}
			
			if secure != textField.secureTextEntry {
				textField.secureTextEntry = secure
			}
			
			if let font = font where font != textField.font {
				textField.font = font
			}
			
			if let color = textColor where color != textField.textColor {
				textField.textColor = color
			}
			
			if borderStyle != textField.borderStyle {
				textField.borderStyle = borderStyle
			}
			
			if keyboardType != textField.keyboardType {
				textField.keyboardType = keyboardType
			}
			
			if returnKeyType != textField.returnKeyType {
				textField.returnKeyType = returnKeyType
			}
			
			if autocorrectionType != textField.autocorrectionType {
				textField.autocorrectionType = autocorrectionType
			}

			if autocapitalizationType != textField.autocapitalizationType {
				textField.autocapitalizationType = autocapitalizationType
			}
		}
	}
	
	public override func createView() -> ViewType {
		let field = UITextField(frame: CGRectZero)
		field.addTarget(actionTrampoline.target, action: actionTrampoline.selector, forControlEvents: .EditingChanged)
		field.delegate = inputDelegate
		field.alpha = alpha
		field.hidden = hidden
		field.enabled = enabled
		field.placeholder = placeholder
		field.secureTextEntry = secure
		field.text = text ?? initialText ?? ""
		field.borderStyle = borderStyle
		field.keyboardType = keyboardType
		field.returnKeyType = returnKeyType
		field.autocorrectionType = autocorrectionType
		field.autocapitalizationType = autocapitalizationType
		if let font = font {
			field.font = font
		}
		if let color = textColor {
			field.textColor = color
		}
		return field
	}
}
