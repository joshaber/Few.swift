//
//  QuickLook.swift
//  Few
//
//  Created by Josh Abernathy on 12/20/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import AppKit

extension Element {
	public func debugQuickLookObject() -> AnyObject? {
		let realizedElement = realizeElementRecursively(self)

		if let view = realizedElement.view {
			let imageRep = view.bitmapImageRepForCachingDisplayInRect(view.bounds)
			if imageRep == nil { return NSImage(size: frame.size) }

			view.cacheDisplayInRect(view.bounds, toBitmapImageRep: imageRep!)

			var image = NSImage(size: imageRep!.size)
			image.addRepresentation(imageRep!)
			return image
		}

		return nil
	}

	public var ql: NSImage {
		return debugQuickLookObject()! as NSImage
	}
}
