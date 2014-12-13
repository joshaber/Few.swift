//
//  Layout.swift
//  Few
//
//  Created by Josh Abernathy on 12/3/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import LlamaKit
import Cartography

struct Properties {
	var width: CGFloat
	var height: CGFloat
	var alphaValue: CGFloat
	var color: NSColor?
}

enum Direction {
	case Up, Down, Left, Right
}

enum PrimitiveElement {
	case Container(position: Position, element: Box<Element2>)
	case Flow(direction: Direction, list: Box<Array<Element2>>)
	case Space
}

struct Element2 {
	var properties: Properties
	let element: PrimitiveElement
}

func width(el: Element2) -> CGFloat {
	return el.properties.width
}

func height(el: Element2) -> CGFloat {
	return el.properties.height
}

func withHeight(height: CGFloat, el: Element2) -> Element2 {
	var el2 = el
	el2.properties.height = height
	
	return el2
}

func withWidth(width: CGFloat, el: Element2) -> Element2 {
	var el2 = el
	el2.properties.width = width

	return el2
}

func withSize(size: CGSize, el: Element2) -> Element2 {
	return withHeight(size.height, withWidth(size.width, el))
}

func size(#el: Element2) -> CGSize {
	return CGSize(width: CGFloat(width(el)), height: CGFloat(height(el)))
}

func makeView(el: Element2) -> NSView {
	let elem = el.element
	switch elem {
	case .Space: empty()
	case let .Container(position, element): return container(position, element.unbox)
	}
}

/// Mutates the given view with the element's properties.
///
/// Returns the mutated view.
func setProperties(element: Element2, view: NSView) -> NSView {
	let properties = element.properties
	let primitiveElement = element.element
	
	view.alphaValue = properties.alphaValue
	
	return view
}

func render(element: Element2) -> NSView {
	return setProperties(element, makeView(element))
}

/// Returns a container view with `element` rendered at `point`.
func container(position: Position, element: Element2) -> NSView {
	var view = render(element)
	view = setPosition(position, element, view)
	
	return view
}

enum Horizontal {
	case Leading, Middle, Trailing
}

enum Vertical {
	case Top, Middle, Bottom
}

/// TODO: We can totally do relative positioning
//enum Pos {
//	case Absolute(Int)
//	case Relative(Float)
//}

struct Position {
	let horizontal: Horizontal
	let vertical: Vertical
	let x: Float
	let y: Float
}


func setPosition(position: Position, element: Element2, view: NSView) -> NSView {
	let primitiveElement = element.element
	let width = element.properties.width
	let height = element.properties.height

	layout(view) { view in
		switch (position.horizontal) {
		case .Leading: view.leading == view.superview!.leading + position.x
		// TODO: Should Middle take `Pos.x` into account?
		case .Middle: view.centerX == view.superview!.centerX
		case .Trailing: view.trailing == view.superview!.trailing - position.x
		}

		switch (position.vertical) {
		case .Top: view.top == view.superview!.top - position.y
		case .Middle: view.centerY == view.superview!.centerY
		case .Bottom: view.bottom == view.superview!.bottom + position.y
		}
	}
	
	return view
}

func empty() -> NSView {
	return NSView(frame: CGRectZero)
}

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
