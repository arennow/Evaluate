//
//  Convenience.swift
//  Evaluate
//
//  Created by Aaron Lynch on 2015-03-25.
//  Copyright (c) 2015 Lithiumcube. All rights reserved.
//

import UIKit

extension UIViewController {
	@IBAction func dismiss() {
		self.dismiss(animated: true, completion: nil)
	}
}

extension CGRect {
	enum VerticalSide {
		case top, bottom
	}
	
	enum HorizontalSide {
		case left, right
	}
	
	func pointInCorner(_ vert: VerticalSide, _ horiz: HorizontalSide) -> CGPoint {
		return CGPoint(
			x: horiz == .left ? self.minX : self.maxX,
			y: vert == .top ? self.minY : self.maxY)
	}
}

extension UIView {
	class func animate(duration: TimeInterval, options: UIViewAnimationOptions, animations: @escaping (() -> ())) {
		return self.animate(withDuration: duration, delay: 0, options: options, animations: animations, completion: nil)
	}
}

func performBlockOnMainThreadAfterDelay(_ delay: Double, block: @escaping () -> Void) {
	DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: block)
}

func <<<T>(lhs: inout [T], rhs: T) {
	lhs.append(rhs)
}

func +=<T>(lhs: inout [T], rhs: [T]) {
	lhs = lhs+rhs
}

func +<K, V>(lhs: Dictionary<K, V>, rhs: Dictionary<K, V>) -> Dictionary<K, V> {
	var outDict = lhs
	
	for (k, v) in rhs {
		outDict[k] = v
	}
	
	return outDict
}

extension Array {
	func optionalValue(at index: Int) -> Element? {
		if index < self.count {
			return self[index]
		} else {
			return nil
		}
	}
}
