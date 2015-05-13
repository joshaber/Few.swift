//
//  TemperatureConverter.swift
//  Few
//
//  Created by Josh Abernathy on 3/10/15.
//  Copyright (c) 2015 Josh Abernathy. All rights reserved.
//

import Foundation
import Few

struct ConverterState {
	static let defaultFahrenheit: CGFloat = 32

	let fahrenheit: CGFloat
	let celcius: CGFloat
	init(fahrenheit: CGFloat = defaultFahrenheit, celcius: CGFloat = f2c(defaultFahrenheit)) {
		self.fahrenheit = fahrenheit
		self.celcius = celcius
	}
}

private func c2f(c: CGFloat) -> CGFloat {
	return (c * 9/5) + 32
}

private func f2c(f: CGFloat) -> CGFloat {
	return (f - 32) * 5/9
}

private func renderLabeledInput(label: String, value: String, autofocus: Bool, fn: String -> ()) -> Element {
	return Element()
		.direction(.Row)
		.padding(Edges(bottom: 4))
		.children([
			Label(label).width(75),
			Input(
				text: value,
				placeholder: label,
				action: fn)
				.autofocus(autofocus)
				.width(100),
		])
}

private func parseFloat(str: String) -> CGFloat? {
	let numberFormatter = NSNumberFormatter()
	return (numberFormatter.numberFromString(str)?.doubleValue).map { CGFloat($0) }
}

typealias TemperatureConverter = TemperatureConverter_<ConverterState>
class TemperatureConverter_<LOL>: Component<ConverterState> {
	init() {
		super.init(initialState: ConverterState());
	}

	override func render() -> Element {
		return Element()
			.justification(.Center)
			.childAlignment(.Center)
			.direction(.Column)
			.children([
				renderLabeledInput("Fahrenheit", "\(state.fahrenheit)", true) {
					if let f = parseFloat($0) {
						self.updateState { _ in ConverterState(fahrenheit: f, celcius: f2c(f)) }
					}
				},
				renderLabeledInput("Celcius", "\(state.celcius)", false) {
					if let c = parseFloat($0) {
						self.updateState { _ in ConverterState(fahrenheit: c2f(c), celcius: c) }
					}
				},
			])
	}
}
