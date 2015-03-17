//
//  Input.swift
//  Few
//
//  Created by Coen Wessels on 14-03-15.
//  Copyright (c) 2015 Josh Abernathy. All rights reserved.
//

import UIKit

public class Input: Element {
    public var text: String?
    public var initialText: String?
    public var placeholder: String?
    public var enabled: Bool
    public var secure: Bool
    
    private var trampoline = TargetActionTrampolineWithSender<UITextField>()
    
    public init(text: String? = nil, initialText: String? = nil, placeholder: String? = nil, enabled: Bool = true, secure: Bool = false, action: String -> () = { _ in }) {
        self.text = text
        self.initialText = initialText
        self.placeholder = placeholder
        self.enabled = enabled
        self.secure = secure
        trampoline.action = { textField in
            action(textField.text)
        }
        
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 23))
    }
    
    // MARK: Element
    
    public override func applyDiff(old: Element, realizedSelf: RealizedElement?) {
        super.applyDiff(old, realizedSelf: realizedSelf)
        
        if let textField = realizedSelf?.view as? UITextField {
            if let oldInput = old as? Input {
                let newTrampoline = oldInput.trampoline
                newTrampoline.action = trampoline.action // Make sure the newest action is used
                trampoline = newTrampoline
            }
            
            if placeholder != textField.placeholder {
                textField.placeholder = placeholder
            }
            
            if let text = text {
                if text != textField.text {
                    textField.text = text
                }
            }
            
            if enabled != textField.enabled {
                textField.enabled = enabled
            }
            
            if secure != textField.secureTextEntry {
                textField.secureTextEntry = secure
            }
        }
    }
    
    public override func createView() -> ViewType {
        let field = UITextField(frame: frame)
        field.addTarget(trampoline.target, action: trampoline.selector, forControlEvents: UIControlEvents.EditingChanged)
        field.alpha = alpha
        field.hidden = hidden
        field.enabled = enabled
        field.placeholder = placeholder
        field.secureTextEntry = secure
        return field
    }
}
