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
	
	public init(_ image: UIImage?, scaling: UIViewContentMode = .ScaleAspectFit) {
		self.image = image
		self.scaling = scaling
		
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
			}
		}
	}
	
	public override func createView() -> ViewType {
		let view = UIImageView(frame: frame)
		view.alpha = alpha
		view.hidden = hidden
		view.image = image
		return view
	}
}
