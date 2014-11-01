//
//  ListCell.swift
//  Few
//
//  Created by Josh Abernathy on 10/16/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation

internal class ListCell: NSTableCellView {
	var element: RealizedElement? {
		didSet {
			if let oldValue = oldValue {
				if let element = element {
					if element.element.canDiff(oldValue.element) {
						if let view = oldValue.view {
							element.element.applyDiff(view, other: oldValue.element)
							return
						}
					}
				}
			}

			oldValue?.view?.removeFromSuperview()
			oldValue?.element.derealize()

			let view = element?.element.realize()
			if let view = view {
				addSubview(view)
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
