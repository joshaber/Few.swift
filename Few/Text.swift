//
//  Text.swift
//  Few
//
//  Created by Josh Vera on 12/13/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import ReactiveCocoa

public func asText<A: Printable>(value: A) -> Element2 {
	let labels: Array<Element2> = [value.description |> label]
	return labels |> flow(Direction.Left)
}

func label(string: String) -> Element2 {
	let properties = Properties(width: 0, height: 0, alphaValue: 1, color: nil)
	return Element2(properties, .Custom(element: Label(text: string)))
}
