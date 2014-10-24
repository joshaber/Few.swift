//
//  ListCell.swift
//  Few
//
//  Created by Josh Abernathy on 10/16/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation

internal class ListCell: NSTableCellView {
	var element: Element? {
		didSet {
			if let oldValue = oldValue {
				if let element = element {
					if element.canDiff(oldValue) {
						element.applyDiff(oldValue)
						return
					}
				}
			}

			oldValue?.derealize()
			element?.realize(self)
			if let view = element?.getContentView() {
				view.autoresizingMask = .ViewWidthSizable | .ViewHeightSizable
				view.frame = bounds
			}
		}
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
	}

	required init?(coder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
}
