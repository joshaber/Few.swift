//
//  Layout.swift
//  Few
//
//  Created by Josh Abernathy on 12/3/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import LlamaKit

enum LayoutF<R> {
	case Beside(left: Box<R>, right: Box<R>)
	case Above(top: Box<R>, bottom: Box<R>)
	case Container(rect: CGRect, r: Box<R>)
	case Embed(el: Element)
}

struct Layout<S> {
	let layoutF: LayoutF<Layout<S>>
	let el: Element
	let state: S

	init(layoutF: LayoutF<Layout<S>>, el: Element, state: S) {
		self.layoutF = layoutF
		self.el = el
		self.state = state
	}
}

func map<A, B>(f: A -> B, l: Layout<A>) -> Layout<B> {
	let newF: LayoutF<Layout<B>> = {
		switch l.layoutF {
		case let .Beside(r, r2):
			let left: Box<Layout<B>> = Box(map(f, r.unbox))
			let right: Box<Layout<B>> = Box(map(f, r.unbox))
			return .Beside(left: left, right: right)
		case let .Above(r, r2):
			return .Above(top: Box(map(f, r.unbox)), bottom: Box(map(f, r2.unbox)))
		case let .Container(rect, r):
			return .Container(rect: rect, r: Box(map(f, r.unbox)))
		case let .Embed(el):
			return .Embed(el: el)
		}
	}()

	return Layout(layoutF: newF, el: l.el, state: f(l.state))
}

func element<S>(#l: Layout<S>) -> Element {
	return l.el
}

func transform<S>(f: Element -> Element, #l: Layout<S>) -> Layout<S> {
	return Layout(layoutF: l.layoutF, el: f(l.el), state: l.state)
}

public func leftAlign(x: CGFloat)(elements: [Element]) -> [Element] {
	for element in elements {
		element.frame.origin.x = x
	}

	return elements
}

public func verticalStack(top: CGFloat, padding: CGFloat)(elements: [Element]) -> [Element] {
	var y = top
	for element in elements {
		if element.hidden { continue }

		y -= element.frame.size.height + padding
		element.frame.origin.y = y
	}

	return elements
}

public func horizontalStack(left: CGFloat, padding: CGFloat)(elements: [Element]) -> [Element] {
	var x = left
	for element in elements {
		if element.hidden { continue }

		x += element.frame.size.width + padding
		element.frame.origin.x = x
	}

	return elements
}

public func offset(x: CGFloat, y: CGFloat)(elements: [Element]) -> [Element] {
	for element in elements {
		element.frame.origin.x += x
		element.frame.origin.y += y
	}

	return elements
}
