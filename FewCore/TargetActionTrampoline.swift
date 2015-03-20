//
//  TargetActionTrampoline.swift
//  Swiftful
//
//  Created by Josh Abernathy on 6/18/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation

internal class TargetActionTrampoline: NSObject {
    internal var action: (() -> ())?
    
    internal let selector = Selector("performAction:")
    
    internal func performAction(sender: AnyObject?) {
        action?()
    }
}

internal class TargetActionTrampolineWithSender<T: AnyObject> {
    internal var target = TargetActionTrampolineProxy()
    internal var selector: Selector {
        return target.selector
    }
    
    internal var action: (T -> ())? {
        get {
            return target.action
        }
        set(newAction) {
            target.action = { obj in
                if let sender = obj as? T {
                    newAction?(sender)
                }
            }
        }
    }
}

internal class TargetActionTrampolineProxy: NSObject {
    internal var action: (AnyObject? -> ())?
    
    private let selector = Selector("performAction:")
    
    internal func performAction(sender: AnyObject?) {
        action?(sender)
    }
}
