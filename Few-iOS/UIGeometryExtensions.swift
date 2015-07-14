
import UIKit

extension UIEdgeInsets: Equatable {
	static let zeroInsets = UIEdgeInsetsZero
}

public func ==(inset0: UIEdgeInsets, inset1: UIEdgeInsets) -> Bool {
	return UIEdgeInsetsEqualToEdgeInsets(inset0, inset1)
}
