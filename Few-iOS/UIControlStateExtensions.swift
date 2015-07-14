
import UIKit

extension UIControlState: Hashable {
	static let all: Set<UIControlState> = {
		var states = Set<UIControlState>()
		for enabled in [false, true] {
			for selected in [false, true] {
				for highlighted in [false, true] {
					let state = UIControlState(enabled: enabled, selected: selected, highlighted: highlighted)
					states.insert(state)
				}
			}
		}
		return states
	}()
	
	public var hashValue: Int {
		return Int(rawValue)
	}
	
	init(enabled: Bool, selected: Bool, highlighted: Bool) {
		var result = UIControlState.Normal
		if !enabled {
			result |= .Disabled
		}
		if selected {
			result |= .Selected
		}
		if highlighted {
			result |= .Highlighted
		}
		self = result
	}
}
