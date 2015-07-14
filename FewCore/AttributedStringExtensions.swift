
import Foundation

extension NSAttributedString: Equatable { }

public func ==(str0: NSAttributedString, str1: NSAttributedString) -> Bool {
	return str0.isEqualToAttributedString(str1)
}