//
//  CurrencyConverter.swift
//  Few
//
//  Created by Josh Abernathy on 3/10/15.
//  Copyright (c) 2015 Josh Abernathy. All rights reserved.
//

import Foundation
import Few

struct ConverterState {
	static let defaultFahrenheit: CGFloat = 32

	let fahrenheit: CGFloat = defaultFahrenheit
	let celcius: CGFloat = f2c(defaultFahrenheit)
}

private func c2f(c: CGFloat) -> CGFloat {
	return (c * 9/5) + 32
}

private func f2c(f: CGFloat) -> CGFloat {
	return (f - 32) * 5/9
}

private func renderLabeledInput(label: String, value: String, autofocus: Bool, fn: String -> ()) -> Element {
	return View()
		.direction(.Row)
		.padding(Edges(bottom: 4))
		.children([
			Label(label).size(75, 19),
			Input(
				text: value,
				placeholder: label,
				enabled: true,
				action: fn)
				.autofocus(autofocus)
				.size(100, 23),
		])
}

private func render(component: Component<ConverterState>, state: ConverterState) -> Element {
	let numberFormatter = NSNumberFormatter()
	let parseNumber: String -> CGFloat? = { str in
		return (numberFormatter.numberFromString(str)?.doubleValue).map { CGFloat($0) }
	}
	return View()
		.justification(.Center)
		.childAlignment(.Center)
		.direction(.Column)
		.children([
			renderLabeledInput("Fahrenheit", "\(state.fahrenheit)", true) {
				if let f = parseNumber($0) {
					component.updateState { _ in ConverterState(fahrenheit: f, celcius: f2c(f)) }
				}
			},
			renderLabeledInput("Celcius", "\(state.celcius)", false) {
				if let c = parseNumber($0) {
					component.updateState { _ in ConverterState(fahrenheit: c2f(c), celcius: c) }
				}
			},
		])
}

let CurrencyConverter: () -> Component<ConverterState> = { Component(initialState: ConverterState(), render: render) }
