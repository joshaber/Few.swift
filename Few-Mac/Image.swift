//
//  Image.swift
//  Few
//
//  Created by Josh Abernathy on 3/3/15.
//  Copyright (c) 2015 Josh Abernathy. All rights reserved.
//

import Foundation
import AppKit

public class Image: Element {
	public var image: NSImage?
	public var scaling: NSImageScaling

	public init(_ image: NSImage?, scaling: NSImageScaling = .ImageScaleProportionallyUpOrDown) {
		self.image = image
		self.scaling = scaling

		let size = image?.size ?? CGSize(width: Node.Undefined, height: Node.Undefined)
		super.init(frame: CGRect(origin: CGPointZero, size: size))
	}

	// MARK: Element

	public override func applyDiff(old: Element, realizedSelf: RealizedElement?) {
		super.applyDiff(old, realizedSelf: realizedSelf)

		if let view = realizedSelf?.view as? NSImageView {
			if view.imageScaling != scaling {
				view.imageScaling = scaling
			}

			if view.image != image {
				view.image = image
				realizedSelf?.markNeedsLayout()
			}
		}
	}

	public override func createView() -> ViewType {
		let view = NSImageView(frame: CGRectZero)
		view.image = image
		view.editable = false
		view.allowsCutCopyPaste = false
		view.animates = true
		view.imageFrameStyle = .None
		view.imageScaling = scaling
		view.alphaValue = alpha
		view.hidden = hidden
		return view
	}
}
