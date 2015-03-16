//
//  Button.swift
//  Few
//
//  Created by Coen Wessels on 13/03/15.
//  Copyright (c) 2015 Josh Abernathy. All rights reserved.
//

import UIKit

private class FewButton: UIButton {
    var touchUpInsideAction: (() -> ())?

    init(frame: CGRect, touchUpInsideAction: () -> ()) {
        super.init(frame: frame)
        self.touchUpInsideAction = touchUpInsideAction
        addTarget(self, action: "touchUpInside", forControlEvents: .TouchUpInside)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func touchUpInside() {
        touchUpInsideAction?()
    }
}

public class Button: Element {
    public var title: NSAttributedString
    public var enabled: Bool
    public var isDefault: Bool
    private var action: () -> ()
    
    public init(title: String, enabled: Bool = true, isDefault: Bool = false, action: () -> () = { }) {
        self.title = NSAttributedString(string: title)
        self.enabled = enabled
        self.isDefault = isDefault
        self.action = action
        
        super.init(frame: CGRect(x: 0, y: 0, width: 50, height: 23))
    }
    
    // MARK: Element
    
    public override func applyDiff(old: Element, realizedSelf: RealizedElement?) {
        super.applyDiff(old, realizedSelf: realizedSelf)
        
        if let button = realizedSelf?.view as? FewButton {
            if title != button.titleLabel?.attributedText {
                button.setAttributedTitle(title, forState: .Normal)
            }
            
            if enabled != button.enabled {
                button.enabled = enabled
            }
        }
    }
    
    public override func createView() -> ViewType {
        let button = FewButton(frame: frame, touchUpInsideAction: action)
        button.alpha = alpha
        button.hidden = hidden
        button.setAttributedTitle(title, forState: .Normal)
        button.setTitleColor(UIColor.blackColor(), forState: .Normal)
        button.enabled = enabled
        return button
    }
}