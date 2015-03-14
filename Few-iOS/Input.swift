//
//  Input.swift
//  Few
//
//  Created by Coen Wessels on 14-03-15.
//  Copyright (c) 2015 Josh Abernathy. All rights reserved.
//

import UIKit

private class FewTextField: UITextField {
    var textChangedAction: (String -> ())?
    
    init(frame: CGRect, textChangedAction: String -> ()) {
        super.init(frame: frame)
        self.textChangedAction = textChangedAction
        addTarget(self, action: "textChanged", forControlEvents: .EditingChanged)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func textChanged() {
        textChangedAction?(text)
    }
}

public class Input: Element {
    public var text: String?
    public var initialText: String?
    public var placeholder: String?
    public var enabled: Bool
    public var secure: Bool
    public var action: String -> ()
    
    public init(text: String? = nil, initialText: String? = nil, placeholder: String? = nil, enabled: Bool = true, secure: Bool = false, action: String -> () = { _ in }) {
        self.text = text
        self.initialText = initialText
        self.placeholder = placeholder
        self.action = action
        self.enabled = enabled
        self.secure = secure
        
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 23))
    }
    
    // MARK: Element
    
    public override func applyDiff(old: Element, realizedSelf: RealizedElement?) {
        super.applyDiff(old, realizedSelf: realizedSelf)
        
        if let textField = realizedSelf?.view as? FewTextField {
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
        let field = FewTextField(frame: frame, textChangedAction: action)
        field.enabled = enabled
        field.placeholder = placeholder
        field.secureTextEntry = secure
        return field
    }
}
