//
//  View.swift
//  Few
//
//  Created by Coen Wessels on 13/03/15.
//  Copyright (c) 2015 Josh Abernathy. All rights reserved.
//

import UIKit

public class View: Element {
    public var backgroundColor: UIColor?
    
    public init(backgroundColor: UIColor? = nil) {
        self.backgroundColor = backgroundColor
    }
    
    // MARK: Element
    
    public override func applyDiff(old: Element, realizedSelf: RealizedElement?) {
        super.applyDiff(old, realizedSelf: realizedSelf)
        
        if let backgroundView = realizedSelf?.view {
            if backgroundColor !== backgroundView.backgroundColor {
                backgroundView.backgroundColor = backgroundColor
            }
        }
    }
    
    public override func createView() -> ViewType {
        let view = UIView(frame: frame)
        view.backgroundColor = backgroundColor
        return view
    }
}