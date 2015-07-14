
import UIKit

public class Switch: Element {
	static let intrinsicSize = UISwitch().intrinsicContentSize()
	
	public init(on: Bool, enabled: Bool = true, animatesOnSetting: Bool = true, onTintColor: UIColor? = nil, tintColor: UIColor? = nil, thumbTintColor: UIColor? = nil, action: (Bool -> Void)? = nil) {
		let initialFrame = CGRect(origin: .zeroPoint, size: Switch.intrinsicSize)
		self.on = on
		self.onTintColor = onTintColor
		self.thumbTintColor = thumbTintColor
		self.tintColor = tintColor
		self.animatesOnSetting = animatesOnSetting
		self.enabled = enabled
		self.action = action
		super.init(frame: initialFrame)
		if let action = action {
			trampoline.action = { aSwitch in action(aSwitch.on) }
		}
	}
	
	private var trampoline = TargetActionTrampolineWithSender<UISwitch>()
	public var on: Bool
	public var enabled: Bool
	public var action: (Bool -> Void)?
	public var animatesOnSetting: Bool

	public var onTintColor: UIColor?
	public var tintColor: UIColor?
	public var thumbTintColor: UIColor?

	public override func applyDiff(old: Element, realizedSelf: RealizedElement?) {
		super.applyDiff(old, realizedSelf: realizedSelf)
		
		if let view = realizedSelf?.view as? UISwitch {
			if let oldSwitch = old as? Switch {
				let newTrampoline = oldSwitch.trampoline
				newTrampoline.action = trampoline.action // Make sure the newest action is used
				trampoline = newTrampoline
			}
			
			if enabled != view.enabled {
				view.enabled = enabled
			}
			
			if on != view.on {
				view.setOn(on, animated: animatesOnSetting)
			}
			
			if view.onTintColor != onTintColor {
				view.onTintColor = onTintColor
			}
			
			if view.tintColor != tintColor {
				view.tintColor = tintColor
			}
			
			if view.thumbTintColor != thumbTintColor {
				view.thumbTintColor = thumbTintColor
			}
		}
	}
	
	public override func createView() -> ViewType? {
		let view = UISwitch()
		view.on = on
		view.enabled = enabled
		view.onTintColor = onTintColor
		view.tintColor = tintColor
		view.thumbTintColor = thumbTintColor
		view.addTarget(trampoline.target, action: trampoline.selector, forControlEvents: .ValueChanged)
		return view
	}
}
