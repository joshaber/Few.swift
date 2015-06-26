//
//  Image.swift
//  Few
//
//  Created by Coen Wessels on 13-03-15.
//  Copyright (c) 2015 Josh Abernathy. All rights reserved.
//

import UIKit

public class Image: Element {
	public var image: UIImage?
	public var scaling: UIViewContentMode
	public var clipsToBounds: Bool
	
	public init(_ image: UIImage?, scaling: UIViewContentMode = .ScaleAspectFit, clipsToBounds: Bool = false) {
		self.image = image
		self.scaling = scaling
		self.clipsToBounds = clipsToBounds
		
		let size = image?.size ?? CGSize(width: Node.Undefined, height: Node.Undefined)
		super.init(frame: CGRect(origin: CGPointZero, size: size))
	}
	
	// MARK: Element
	
	public override func applyDiff(old: Element, realizedSelf: RealizedElement?) {
		super.applyDiff(old, realizedSelf: realizedSelf)
		
		if let view = realizedSelf?.view as? UIImageView {
			if view.contentMode != scaling {
				view.contentMode = scaling
			}
			
			if view.image != image {
				view.image = image
				realizedSelf?.markNeedsLayout()
			}
			
			if view.clipsToBounds != clipsToBounds {
				view.clipsToBounds = clipsToBounds
			}
		}
	}
	
	public override func createView() -> ViewType {
		let view = UIImageView(frame: CGRectZero)
		view.alpha = alpha
		view.hidden = hidden
		view.image = image
		view.contentMode = scaling
		view.clipsToBounds = clipsToBounds
		return view
	}
}
