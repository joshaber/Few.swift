//
//  ViewController.swift
//  FewDemo-iOS
//
//  Created by Coen Wessels on 13/03/15.
//  Copyright (c) 2015 Josh Abernathy. All rights reserved.
//

import UIKit
import Few

func renderCounter(component: Component<Int>, count: Int) -> Element {
	let updateCounter = { component.updateState { $0 + 1 } }

	return Element()
		// The view itself should be centered.
		.justification(.Center)
		// The children should be centered in the view.
		.childAlignment(.Center)
		// Layout children in a column.
		.direction(.Column)
		.flex(1)
		.children([
			Label("You've clicked \(count) times!"),
			Button(attributedTitle: NSAttributedString(string: "Click me!"), action: updateCounter)
				.margin(Edges(uniform: 10))
				.width(100),
			])
}

let Counter = { Component(initialState: 0, render: renderCounter) }

private func renderRow1(row: Int) -> Element {
	return Element()
		.direction(.Row)
		.padding(Edges(uniform: 10))
		.children([
			Image(UIImage(named: "Apple_Swift_Logo.png"))
				.size(42, 42)
				.selfAlignment(.FlexStart),
			Element()
				.margin(Edges(left: 10))
				.direction(.Column)
				.children([
					Label("I am a banana.", textColor: UIColor.blackColor(), font: UIFont.systemFontOfSize(18)),
					Label("\(row)", textColor: UIColor.greenColor())
					])
			])
}

private func renderRow2(row: Int) -> Element {
	return Element()
		.direction(.Row)
		.padding(Edges(uniform: 10))
		.children([
			Image(UIImage(named: "Apple_Swift_Logo.png"))
				.size(42, 42)
				.selfAlignment(.FlexStart),
			Element()
				.margin(Edges(left: 10))
				.direction(.Column)
				.children([
					Label("I am a banana.", textColor: UIColor.redColor(), font: UIFont.systemFontOfSize(18)),
					Label("\(row)", textColor: UIColor.greenColor())
					])
			])
}

struct TableViewDemoState {
	var headerHeight: CGFloat
	var footerHeight: CGFloat
}

func renderTableView(component: Component<TableViewDemoState>, state: TableViewDemoState) -> Element {
	let elements: [Element] = Array(1...100).map { rowNum in
		if rowNum % 2 == 0 {
			return renderRow1(rowNum)
		} else {
			return renderRow2(rowNum)
		}
	}
	return TableView([elements], sectionHeaders: [Label("Section Header!")],
		header: Button(attributedTitle: NSAttributedString(string: "Increase Header Height"),
			action: {
				component.updateState { (var state) in
					state.headerHeight += 10
					return state
				}
			}).height(state.headerHeight).width(200),
		footer: Button(attributedTitle: NSAttributedString(string: "Increase Footer Height"),
			action: {
				component.updateState { (var state) in
					state.footerHeight += 10
					return state
				}
			}).height(state.footerHeight).width(200),
		sectionFooters: [Label("Section Footer!")],
		selectionChanged: println)
		.flex(1)
}

let TableViewDemo = { Component(initialState: TableViewDemoState(headerHeight: 60, footerHeight: 60), render: renderTableView) }

func renderInput(component: Component<String>, state: String) -> Element {
	return Element()
		.justification(.Center)
		.childAlignment(.Center)
		.flex(1)
		.children([
			View(backgroundColor: UIColor.greenColor())
				.direction(.Column)
				.children([
					View(backgroundColor: UIColor.blueColor(), borderColor: UIColor.blackColor(), borderWidth: 2, cornerRadius: 5)
						.margin(Edges(uniform: 10))
						.size(100, 100),
					Input(placeholder: "Username")
						.margin(Edges(uniform: 10)),
					Input(placeholder: "Password", secure: true)
						.margin(Edges(uniform: 10))
				])
		])
}
let InputDemo = { Component(initialState: "", render: renderInput) }

struct AppState {
	let tableViewComponent: Component<TableViewDemoState>
	let counterComponent: Component<Int>
	let inputComponent: Component<String>
	
	var activeComponent: ActiveComponent
	
	mutating func updateActiveComponent(newComponent: ActiveComponent) -> AppState {
		activeComponent = newComponent
		return self
	}
}
enum ActiveComponent {
	case TableView
	case Counter
	case Input
}

func renderApp(component: Component<AppState>, state: AppState) -> Element {
	var contentComponent: Element!
	switch state.activeComponent {
	case .TableView:
		contentComponent = state.tableViewComponent
	case .Counter:
		contentComponent = state.counterComponent
	case .Input:
		contentComponent = state.inputComponent
	}
	
	let showMore = { component.updateState(toggleDisplay) }
	return Element()
		.direction(.Column)
		.children([
			Element()
				.children([
					contentComponent.flex(1)
				])
				.flex(1),
			Button(attributedTitle: NSAttributedString(string: "Show me more!"), action: showMore)
				.width(200)
				.margin(Edges(uniform: 10))
				.selfAlignment(.Center)
		])
}

func toggleDisplay(var state: AppState) -> AppState {
	switch state.activeComponent {
	case .TableView:
		return state.updateActiveComponent(.Counter)
	case .Counter:
		return state.updateActiveComponent(.Input)
	case .Input:
		return state.updateActiveComponent(.TableView)
	}
}

