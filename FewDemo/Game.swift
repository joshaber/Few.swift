//
//  Game.swift
//  Few
//
//  Created by Josh Abernathy on 8/19/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import AppKit
import Few

struct GameState {
	enum State {
		case Playing
		case Done
	}
	
	let winningScore: Int
	let count: Int
	let state: State

	init(winningScore: Int, state: State, count: Int = 0) {
		self.winningScore = winningScore
		self.count = count
		self.state = state
	}
}

// TODO: We should really be using lenses here.
func mapCount(state: GameState, fn: Int -> Int) -> GameState {
	let newCount = fn(state.count)
	if state.state == .Playing && newCount >= state.winningScore {
		return GameState(winningScore: state.winningScore, state: .Done, count: fn(state.count))
	} else {
		return GameState(winningScore: state.winningScore, state: state.state, count: newCount)
	}
}

func renderForm(state: GameState) -> Element {
	let incButton = Button(title: "Increment", fn: { mapCount($0, inc) })
				 |> sizeToFit
				 |> offset(0, 40)

	let decButton = Button(title: "Decrement", fn: { mapCount($0, dec) })
				 |> sizeToFit

	let count = Label(text: "\(state.count)")
			 |> sizeToFit
			 |> offset(0, 20)

	return offset(incButton + count + decButton, 200, 200)
}

func renderBackground(state: GameState) -> Element {
	var element: Element = empty()
	if state.count < 0 {
		element = fillRect(NSColor.redColor().colorWithAlphaComponent(0.5))
	} else if state.count > 0 {
		element = fillRect(NSColor.greenColor().colorWithAlphaComponent(0.5))
	}
	
	return sized(element, CGSize(width: 1000, height: 1000))
}

func renderLost() -> Element {
	return Label(text: "Y O U  L O S E")
		|> sizeToFit
		|> absolute(CGPoint(x: 200, y: 225))
}

func renderWon() -> Element {
	return Label(text: "Y O U  W I N")
		|> sizeToFit
		|> absolute(CGPoint(x: 200, y: 225))
}

func renderReset(state: GameState) -> Element {
	return Button(title: "Reset", fn: const(GameState(winningScore: state.winningScore, state: .Playing)))
		|> sizeToFit
		|> absolute(CGPoint(x: 200, y: 180))
}

func renderScoreLimit(state: GameState) -> Element {
	return Input<GameState>(text: "\(state.winningScore)", fn: { str, s in
		let scanner = NSScanner(string: str)
		var limit = 0
		let success = scanner.scanInteger(&limit)
		if success && limit > 0 {
			return GameState(winningScore: limit, state: s.state, count: 0)
		} else {
			return s
		}
	})
		|> sized(CGSize(width: 100, height: 23))
		|> absolute(CGPoint(x: 0, y: 0))
}

func renderGame(state: GameState) -> Element {
	let bg = renderBackground(state)
	if state.count <= -state.winningScore {
		return bg + renderLost() + renderReset(state)
	} else if state.count >= state.winningScore {
		return bg + renderWon() + renderReset(state)
	} else {
		return bg + renderForm(state) + renderScoreLimit(state)
	}
}

let gameComponent = Component(render: renderGame, initialState: GameState(winningScore: 5, state: .Playing))
