//
//  Button.swift
//  Few
//
//  Created by Coen Wessels on 13/03/15.
//  Copyright (c) 2015 Josh Abernathy. All rights reserved.
//

import UIKit

public class Button: Element {
    public var title: String
    public var enabled: Bool
    public var isDefault: Bool
    
    private let trampoline = TargetActionTrampoline()
    
    public init(title: String, enabled: Bool = true, isDefault: Bool = false, action: () -> () = { }) {
        self.title = title
        self.enabled = enabled
        self.isDefault = isDefault
        
        super.init(frame: CGRect(x: 0, y: 0, width: 50, height: 23))
        
        self.trampoline.action = action
    }
    
    // MARK: Element
    
    public override func applyDiff(old: Element, realizedSelf: RealizedElement?) {
        super.applyDiff(old, realizedSelf: realizedSelf)
        
        if let button = realizedSelf?.view as? UIButton {
            if title != button.titleLabel?.text {
                button.setTitle(title, forState: .Normal)
            }
            
            if enabled != button.enabled {
                button.enabled = enabled
            }
        }
    }
    
    public override func createView() -> ViewType {
        let button = UIButton(frame: frame)
        button.setTitle(title, forState: .Normal)
        button.setTitleColor(UIColor.blackColor(), forState: .Normal)
        button.enabled = enabled
        button.addTarget(trampoline, action: trampoline.selector, forControlEvents: .TouchUpInside)
        return button
    }
}