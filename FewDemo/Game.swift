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
	let winningScore: Int
	let count: Int = 0

	init(winningScore: Int, count: Int = 0) {
		self.winningScore = winningScore
		self.count = count
	}
}

extension GameState: Equatable {}

func ==(lhs: GameState, rhs: GameState) -> Bool {
	return rhs.winningScore == lhs.winningScore && rhs.count == lhs.count
}

// TODO: We should really be using lenses here.
func mapCount(state: GameState, fn: Int -> Int) -> GameState {
	return GameState(winningScore: state.winningScore, count: fn(state.count))
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
	
	return absolute(element, CGSize(width: 1000, height: 1000))
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
	return Button(title: "Reset", fn: const(GameState(winningScore: state.winningScore, count: 0)))
		|> sizeToFit
		|> absolute(CGPoint(x: 200, y: 180))
}

func renderGame(state: GameState) -> Element {
	let bg = renderBackground(state)
	if state.count <= -state.winningScore {
		return bg + renderLost() + renderReset(state)
	} else if state.count >= state.winningScore {
		return bg + renderWon() + renderReset(state)
	} else {
		return bg + renderForm(state)
	}
}
